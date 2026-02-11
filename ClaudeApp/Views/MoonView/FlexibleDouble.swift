//
//  FlexibleDouble.swift
//  LadiesApp
//
//  Created by Marta Maria Ries on 12/15/25.
//


import Foundation

/// Decodes a number that may arrive as a JSON number OR a JSON string (e.g. "0.73").
struct FlexibleDouble: Decodable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let d = try? container.decode(Double.self) {
            value = d
            return
        }
        if let i = try? container.decode(Int.self) {
            value = Double(i)
            return
        }
        if let s = try? container.decode(String.self) {
            // USNO sometimes returns numeric fields as strings
            let normalized = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if let d = Double(normalized) {
                value = d
                return
            }
        }

        throw DecodingError.typeMismatch(
            Double.self,
            .init(codingPath: decoder.codingPath,
                  debugDescription: "Expected Double/Int/String convertible to Double.")
        )
    }
}
