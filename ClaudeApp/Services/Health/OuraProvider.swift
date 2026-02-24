import Foundation
import AuthenticationServices

@Observable
final class OuraProvider: NSObject, @unchecked Sendable, HealthDataProvider {
    let sourceType: HealthDataSourceType = .ouraRing

    private(set) var connectionState: HealthConnectionState = .disconnected
    private(set) var isAuthorized = false

    // OAuth configuration — fill in your Oura app credentials
    private let clientId = "YOUR_OURA_CLIENT_ID"
    private let clientSecret = "YOUR_OURA_CLIENT_SECRET"
    private let redirectURI = "claudeapp://oura-callback"
    private let authURL = "https://cloud.ouraring.com/oauth/authorize"
    private let tokenURL = "https://api.ouraring.com/oauth/token"
    private let baseAPIURL = "https://api.ouraring.com/v2/usercollection"

    private let keychainAccessTokenKey = "oura_access_token"
    private let keychainRefreshTokenKey = "oura_refresh_token"

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f
    }()

    override init() {
        super.init()
        // Check for existing token
        if KeychainHelper.loadString(key: keychainAccessTokenKey) != nil {
            isAuthorized = true
            connectionState = .connected
        }
    }

    // MARK: - Connection (OAuth)

    func connect() async throws {
        connectionState = .connecting

        let code = try await startOAuthFlow()
        let tokens = try await exchangeCodeForTokens(code: code)
        try saveTokens(tokens)

        isAuthorized = true
        connectionState = .connected
    }

    func disconnect() {
        KeychainHelper.delete(key: keychainAccessTokenKey)
        KeychainHelper.delete(key: keychainRefreshTokenKey)
        isAuthorized = false
        connectionState = .disconnected
    }

    // MARK: - OAuth Flow

    @MainActor
    private func startOAuthFlow() async throws -> String {
        var components = URLComponents(string: authURL)!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: "daily heartrate personal session sleep spo2")
        ]

        guard let url = components.url else {
            throw OuraError.invalidURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "claudeapp"
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: OuraError.authCodeMissing)
                    return
                }
                continuation.resume(returning: code)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
    }

    private func exchangeCodeForTokens(code: String) async throws -> OuraTokenResponse {
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "grant_type=authorization_code",
            "code=\(code)",
            "redirect_uri=\(redirectURI)",
            "client_id=\(clientId)",
            "client_secret=\(clientSecret)"
        ].joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw OuraError.tokenExchangeFailed
        }

        return try JSONDecoder().decode(OuraTokenResponse.self, from: data)
    }

    private func refreshAccessToken() async throws {
        guard let refreshToken = KeychainHelper.loadString(key: keychainRefreshTokenKey) else {
            throw OuraError.noRefreshToken
        }

        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "grant_type=refresh_token",
            "refresh_token=\(refreshToken)",
            "client_id=\(clientId)",
            "client_secret=\(clientSecret)"
        ].joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw OuraError.tokenRefreshFailed
        }

        let tokens = try JSONDecoder().decode(OuraTokenResponse.self, from: data)
        try saveTokens(tokens)
    }

    private func saveTokens(_ tokens: OuraTokenResponse) throws {
        try KeychainHelper.saveString(key: keychainAccessTokenKey, value: tokens.accessToken)
        if let refresh = tokens.refreshToken {
            try KeychainHelper.saveString(key: keychainRefreshTokenKey, value: refresh)
        }
    }

    // MARK: - API Requests

    private func authenticatedRequest(url: URL) async throws -> Data {
        guard let token = KeychainHelper.loadString(key: keychainAccessTokenKey) else {
            throw OuraError.notAuthenticated
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            // Try refresh
            try await refreshAccessToken()
            guard let newToken = KeychainHelper.loadString(key: keychainAccessTokenKey) else {
                throw OuraError.notAuthenticated
            }
            var retryRequest = URLRequest(url: url)
            retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
            let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
            guard let retryHttp = retryResponse as? HTTPURLResponse, retryHttp.statusCode == 200 else {
                throw OuraError.requestFailed
            }
            return retryData
        }

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw OuraError.requestFailed
        }

        return data
    }

    // MARK: - Fetch Daily Summary

    func fetchDailySummary(for date: Date) async throws -> DailyHealthSummary? {
        let dayString = dateFormatter.string(from: date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        let nextDayString = dateFormatter.string(from: nextDay)

        async let sleepData = fetchSleep(start: dayString, end: nextDayString)
        async let readinessData = fetchReadiness(start: dayString, end: nextDayString)
        async let activityData = fetchActivity(start: dayString, end: nextDayString)
        async let heartRateData = fetchRestingHeartRate(start: dayString, end: nextDayString)

        let sleep = try await sleepData
        let readiness = try await readinessData
        let activity = try await activityData
        let rhr = try await heartRateData

        guard sleep != nil || readiness != nil || activity != nil || rhr != nil else {
            return nil
        }

        var summary = DailyHealthSummary(
            date: Calendar.current.startOfDay(for: date),
            source: .ouraRing
        )

        if let sleepDoc = sleep {
            var sleepSummary = DailySleepSummary(
                totalDurationHours: Double(sleepDoc.totalSleepDuration ?? 0) / 3600.0
            )
            if let deep = sleepDoc.deepSleepDuration { sleepSummary.deepSleepHours = Double(deep) / 3600.0 }
            if let rem = sleepDoc.remSleepDuration { sleepSummary.remSleepHours = Double(rem) / 3600.0 }
            if let light = sleepDoc.lightSleepDuration { sleepSummary.lightSleepHours = Double(light) / 3600.0 }
            sleepSummary.qualityScore = sleepDoc.sleepScoreTotal
            summary.sleep = sleepSummary
        }

        if let readinessDoc = readiness {
            if let deviation = readinessDoc.temperatureDeviation {
                // Oura gives deviation from baseline; approximate baseline ~36.6C
                summary.basalBodyTemperatureCelsius = 36.6 + deviation
            }
        }

        summary.steps = activity?.steps
        summary.restingHeartRateBpm = rhr

        return summary
    }

    func fetchDailySummaries(from startDate: Date, to endDate: Date) async throws -> [DailyHealthSummary] {
        var summaries: [DailyHealthSummary] = []
        var current = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)

        while current <= end {
            if let summary = try await fetchDailySummary(for: current) {
                summaries.append(summary)
            }
            guard let next = Calendar.current.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return summaries
    }

    // MARK: - Individual API Calls

    private func fetchSleep(start: String, end: String) async throws -> OuraSleepDocument? {
        var components = URLComponents(string: "\(baseAPIURL)/sleep")!
        components.queryItems = [
            URLQueryItem(name: "start_date", value: start),
            URLQueryItem(name: "end_date", value: end)
        ]
        let data = try await authenticatedRequest(url: components.url!)
        let response = try JSONDecoder().decode(OuraSleepResponse.self, from: data)
        return response.data.first
    }

    private func fetchReadiness(start: String, end: String) async throws -> OuraReadinessDocument? {
        var components = URLComponents(string: "\(baseAPIURL)/daily_readiness")!
        components.queryItems = [
            URLQueryItem(name: "start_date", value: start),
            URLQueryItem(name: "end_date", value: end)
        ]
        let data = try await authenticatedRequest(url: components.url!)
        let response = try JSONDecoder().decode(OuraReadinessResponse.self, from: data)
        return response.data.first
    }

    private func fetchActivity(start: String, end: String) async throws -> OuraActivityDocument? {
        var components = URLComponents(string: "\(baseAPIURL)/daily_activity")!
        components.queryItems = [
            URLQueryItem(name: "start_date", value: start),
            URLQueryItem(name: "end_date", value: end)
        ]
        let data = try await authenticatedRequest(url: components.url!)
        let response = try JSONDecoder().decode(OuraActivityResponse.self, from: data)
        return response.data.first
    }

    private func fetchRestingHeartRate(start: String, end: String) async throws -> Double? {
        var components = URLComponents(string: "\(baseAPIURL)/heart_rate")!
        components.queryItems = [
            URLQueryItem(name: "start_date", value: start),
            URLQueryItem(name: "end_date", value: end)
        ]
        let data = try await authenticatedRequest(url: components.url!)
        let response = try JSONDecoder().decode(OuraHeartRateResponse.self, from: data)
        // Filter for "rest" source and average
        let restSamples = response.data.filter { $0.source == "rest" }
        guard !restSamples.isEmpty else { return nil }
        let avg = Double(restSamples.reduce(0) { $0 + $1.bpm }) / Double(restSamples.count)
        return avg
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension OuraProvider: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

// MARK: - Errors

enum OuraError: LocalizedError {
    case invalidURL
    case authCodeMissing
    case tokenExchangeFailed
    case tokenRefreshFailed
    case noRefreshToken
    case notAuthenticated
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid Oura URL"
        case .authCodeMissing: "Authorization code not received"
        case .tokenExchangeFailed: "Failed to exchange authorization code"
        case .tokenRefreshFailed: "Failed to refresh access token"
        case .noRefreshToken: "No refresh token available"
        case .notAuthenticated: "Not authenticated with Oura"
        case .requestFailed: "Oura API request failed"
        }
    }
}
