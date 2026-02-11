import Foundation

struct USNOResponse: Decodable {
    let error: String?
    let properties: Properties?

    struct Properties: Decodable {
        let data: DataBlock?
    }

    struct DataBlock: Decodable {
        let curphase: String?
        let fracillum: String?   // USNO often returns this as a string :contentReference[oaicite:1]{index=1}
    }
}

struct USNOAPIError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

import Foundation

final class MoonService {

    static let shared = MoonService()
    private init() {}

    /// Returns normalized moon phase: 0.0 = New → 0.5 = Full → 1.0 = New
    func fetchMoonPhase(latitude: Double, longitude: Double, date: Date = Date()) async throws -> Double {

        let dateString = Self.usnoDateString(date)

        // USNO API template: /api/rstt/oneday?date=DATE&coords=LAT,LON&tz=TZ :contentReference[oaicite:2]{index=2}
        let urlString =
        "https://aa.usno.navy.mil/api/rstt/oneday" +
        "?date=\(dateString)" +
        "&coords=\(latitude),\(longitude)" +
        "&tz=0"

        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            let body = String(data: data, encoding: .utf8) ?? "<empty>"
            throw USNOAPIError(message: "USNO HTTP error: \(body)")
        }

        let decoded = try JSONDecoder().decode(USNOResponse.self, from: data)

        if let err = decoded.error, !err.isEmpty {
            throw USNOAPIError(message: "USNO error: \(err)")
        }

        guard let dataBlock = decoded.properties?.data else {
            throw USNOAPIError(message: "USNO missing properties.data")
        }

        guard let illumString = dataBlock.fracillum else {
            // Helpful debug once:
            let body = String(data: data, encoding: .utf8) ?? "<empty>"
            throw USNOAPIError(message: "USNO missing fracillum. Body: \(body)")
        }

        guard let illum = Self.parseIllumination(illumString) else {
            let body = String(data: data, encoding: .utf8) ?? "<empty>"
            throw USNOAPIError(message: "USNO invalid fracillum='\(illumString)'. Body: \(body)")
        }

        let phaseText = dataBlock.curphase ?? ""
        let isWaxing = phaseText.localizedCaseInsensitiveContains("waxing")

        // Convert illumination → phase position
        // k = (1 - cos(D)) / 2  →  D = acos(1 - 2k)
        let k = max(0.0, min(1.0, illum))
        let D = acos(1.0 - 2.0 * k)               // 0 → π
        let halfCycle = D / (2.0 * Double.pi)     // 0 → 0.5

        let normalized = isWaxing ? halfCycle : (1.0 - halfCycle)
        return max(0.0, min(1.0, normalized))
    }

    private static func parseIllumination(_ raw: String) -> Double? {
        // Handles: "0.73", "0.73 ", "73%", "73 %", "0,73"
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // remove percent signs/spaces
        s = s.replacingOccurrences(of: "%", with: "")
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)

        // allow comma decimals
        s = s.replacingOccurrences(of: ",", with: ".")

        if let v = Double(s) {
            // If USNO ever returns 0..100 instead of 0..1, normalize it.
            return v > 1.0 ? (v / 100.0) : v
        }
        return nil
    }

    private static func usnoDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
