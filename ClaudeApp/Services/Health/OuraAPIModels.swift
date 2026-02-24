import Foundation

// MARK: - OAuth Token Response

struct OuraTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

// MARK: - Sleep API Response

struct OuraSleepResponse: Codable {
    let data: [OuraSleepDocument]
}

struct OuraSleepDocument: Codable {
    let id: String
    let day: String  // "YYYY-MM-DD"
    let bedtimeStart: String?
    let bedtimeEnd: String?
    let totalSleepDuration: Int?  // seconds
    let deepSleepDuration: Int?
    let remSleepDuration: Int?
    let lightSleepDuration: Int?
    let sleepScoreTotal: Int?

    enum CodingKeys: String, CodingKey {
        case id, day
        case bedtimeStart = "bedtime_start"
        case bedtimeEnd = "bedtime_end"
        case totalSleepDuration = "total_sleep_duration"
        case deepSleepDuration = "deep_sleep_duration"
        case remSleepDuration = "rem_sleep_duration"
        case lightSleepDuration = "light_sleep_duration"
        case sleepScoreTotal = "sleep_score_total"
    }
}

// MARK: - Daily Readiness API Response

struct OuraReadinessResponse: Codable {
    let data: [OuraReadinessDocument]
}

struct OuraReadinessDocument: Codable {
    let id: String
    let day: String
    let score: Int?
    let temperatureDeviation: Double?
    let temperatureTrendDeviation: Double?

    enum CodingKeys: String, CodingKey {
        case id, day, score
        case temperatureDeviation = "temperature_deviation"
        case temperatureTrendDeviation = "temperature_trend_deviation"
    }
}

// MARK: - Heart Rate API Response

struct OuraHeartRateResponse: Codable {
    let data: [OuraHeartRateDocument]
}

struct OuraHeartRateDocument: Codable {
    let bpm: Int
    let source: String
    let timestamp: String
}

// MARK: - Daily Activity API Response

struct OuraActivityResponse: Codable {
    let data: [OuraActivityDocument]
}

struct OuraActivityDocument: Codable {
    let id: String
    let day: String
    let steps: Int?
}

// MARK: - HRV API Response

struct OuraSleepTimeResponse: Codable {
    let data: [OuraSleepTimeDocument]
}

struct OuraSleepTimeDocument: Codable {
    let id: String
    let day: String
    let hrv: OuraHRVData?

    struct OuraHRVData: Codable {
        let items: [Int?]?
    }
}
