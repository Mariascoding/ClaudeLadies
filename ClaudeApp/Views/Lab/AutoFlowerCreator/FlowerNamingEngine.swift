import Foundation

/// Generates a poetic flower name from a person's input name.
///
/// The function is pure and deterministic — same input always returns the
/// same flower name. If the cleaned name starts with a known flower prefix
/// (longest match wins) it returns that real flower; otherwise it invents
/// a soft botanical-sounding name from the input + a sacred-feminine suffix.
enum FlowerNamingEngine {

    /// Ordered prefix table — longest prefixes MUST come first so that
    /// "lil" beats "li" and "vio" beats "vi".
    private static let prefixTable: [(prefix: String, flower: String)] = [
        // 3-letter prefixes
        ("lil", "Lily"),
        ("ros", "Rose"),
        ("iri", "Iris"),
        ("dai", "Daisy"),
        ("mag", "Magnolia"),
        ("ivy", "Ivy"),
        ("vio", "Violet"),
        ("jas", "Jasmine"),
        ("mar", "Marigold"),
        ("dah", "Dahlia"),
        ("cam", "Camellia"),
        // 2-letter prefixes
        ("lo", "Lotus"),
        ("po", "Poppy"),
        ("az", "Azalea"),
        ("an", "Anemone"),
        ("fl", "Flora"),
        ("pe", "Peony"),
        ("or", "Orchid"),
        ("ce", "Cecelia"),
        ("vi", "Vinca"),
        ("ru", "Rue"),
        ("he", "Heather"),
        ("ja", "Jasmine"),
        ("wi", "Wisteria")
    ]

    private static let invSuffixes: [String] = [
        "elle", "iana", "osa", "ara", "ella", "yana", "ira", "ora"
    ]

    static func flowerName(for inputName: String) -> String {
        let cleaned = normalize(inputName)
        guard !cleaned.isEmpty else { return "Wildflower" }

        // 1. Real-flower prefix lookup (longest prefix wins thanks to ordering)
        for entry in prefixTable {
            if cleaned.hasPrefix(entry.prefix) {
                return entry.flower
            }
        }

        // 2. Invented botanical fallback
        let stemLength = min(4, cleaned.count)
        let stem = String(cleaned.prefix(stemLength))
        let suffix = invSuffixes[deterministicIndex(cleaned, modulo: invSuffixes.count)]
        return (stem + suffix).capitalized
    }

    // MARK: - Helpers

    private static func normalize(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return String(trimmed.unicodeScalars.filter { CharacterSet.lowercaseLetters.contains($0) })
    }

    /// Stable djb2 hash → bounded index. Deterministic across runs.
    private static func deterministicIndex(_ s: String, modulo: Int) -> Int {
        var hash: UInt64 = 5381
        for byte in s.utf8 {
            hash = ((hash &<< 5) &+ hash) &+ UInt64(byte)
        }
        return Int(hash % UInt64(modulo))
    }
}
