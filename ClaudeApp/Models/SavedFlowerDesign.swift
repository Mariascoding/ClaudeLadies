import Foundation
import SwiftUI
import SwiftData
import UIKit

@Model
final class SavedFlowerDesign {
    var name: String
    var createdDate: Date

    // Design enums stored as raw strings
    var outerDesignRaw: String
    var innerDesignRaw: String
    var stamenDesignRaw: String
    var centerDesignRaw: String

    // Colors stored as "R,G,B" component strings (0.0–1.0)
    var outerColorRaw: String
    var innerColorRaw: String
    var stamenColorRaw: String
    var centerColorRaw: String

    // Geometry values
    var outerCount: Int
    var backCount: Int
    var innerCount: Int
    var petalWidth: Double
    var innerWidth: Double
    var centerScale: Double
    var stamenScale: Double
    var outerGradientStrength: Double = 0
    var innerGradientStrength: Double = 0

    // Per-petal color overrides — JSON-encoded [String: String] where values are "R,G,B"
    var petalColorsRaw: String = ""

    init(
        name: String,
        outerDesign: OuterPetalDesign,
        innerDesign: InnerPetalDesign,
        stamenDesign: StamenDesign,
        centerDesign: CenterDesign,
        outerColor: Color,
        innerColor: Color,
        stamenColor: Color,
        centerColor: Color,
        geometry: FlowerGeometry,
        petalColors: [String: Color] = [:]
    ) {
        self.name = name
        self.createdDate = Date()
        self.outerDesignRaw = outerDesign.rawValue
        self.innerDesignRaw = innerDesign.rawValue
        self.stamenDesignRaw = stamenDesign.rawValue
        self.centerDesignRaw = centerDesign.rawValue
        self.outerColorRaw = Self.encode(outerColor)
        self.innerColorRaw = Self.encode(innerColor)
        self.stamenColorRaw = Self.encode(stamenColor)
        self.centerColorRaw = Self.encode(centerColor)
        self.outerCount = geometry.outerCount
        self.backCount = geometry.backCount
        self.innerCount = geometry.innerCount
        self.petalWidth = Double(geometry.petalWidth)
        self.innerWidth = Double(geometry.innerWidth)
        self.centerScale = Double(geometry.centerScale)
        self.stamenScale = Double(geometry.stamenScale)
        self.outerGradientStrength = Double(geometry.outerGradientStrength)
        self.innerGradientStrength = Double(geometry.innerGradientStrength)
        self.petalColorOverrides = petalColors
    }

    // MARK: - Color Encoding

    private static func encode(_ color: Color) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: nil)
        return "\(r),\(g),\(b)"
    }

    private static func decode(_ raw: String) -> Color {
        let parts = raw.split(separator: ",").compactMap { Double($0) }
        if parts.count == 3 {
            return Color(red: parts[0], green: parts[1], blue: parts[2])
        }
        // Fallback: try interpreting as a FlowerColor raw value (legacy data)
        if let fc = FlowerColor(rawValue: raw) {
            return fc.color
        }
        return .appRose
    }

    // MARK: - Computed Accessors

    var outerDesign: OuterPetalDesign {
        get { OuterPetalDesign(rawValue: outerDesignRaw) ?? .classic }
        set { outerDesignRaw = newValue.rawValue }
    }

    var innerDesign: InnerPetalDesign {
        get { InnerPetalDesign(rawValue: innerDesignRaw) ?? .tulip }
        set { innerDesignRaw = newValue.rawValue }
    }

    var stamenDesign: StamenDesign {
        get { StamenDesign(rawValue: stamenDesignRaw) ?? .dewdrops }
        set { stamenDesignRaw = newValue.rawValue }
    }

    var centerDesign: CenterDesign {
        get { CenterDesign(rawValue: centerDesignRaw) ?? .smooth }
        set { centerDesignRaw = newValue.rawValue }
    }

    var outerColor: Color {
        get { Self.decode(outerColorRaw) }
        set { outerColorRaw = Self.encode(newValue) }
    }

    var innerColor: Color {
        get { Self.decode(innerColorRaw) }
        set { innerColorRaw = Self.encode(newValue) }
    }

    var stamenColor: Color {
        get { Self.decode(stamenColorRaw) }
        set { stamenColorRaw = Self.encode(newValue) }
    }

    var centerColor: Color {
        get { Self.decode(centerColorRaw) }
        set { centerColorRaw = Self.encode(newValue) }
    }

    var geometry: FlowerGeometry {
        FlowerGeometry(
            outerCount: outerCount,
            backCount: backCount,
            innerCount: innerCount,
            petalWidth: CGFloat(petalWidth),
            innerWidth: CGFloat(innerWidth),
            centerScale: CGFloat(centerScale),
            stamenScale: CGFloat(stamenScale),
            outerGradientStrength: CGFloat(outerGradientStrength),
            innerGradientStrength: CGFloat(innerGradientStrength)
        )
    }

    // MARK: - Per-Petal Color Overrides

    var petalColorOverrides: [String: Color] {
        get {
            guard !petalColorsRaw.isEmpty,
                  let data = petalColorsRaw.data(using: .utf8),
                  let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
                return [:]
            }
            var result: [String: Color] = [:]
            for (key, value) in dict {
                result[key] = Self.decode(value)
            }
            return result
        }
        set {
            if newValue.isEmpty {
                petalColorsRaw = ""
                return
            }
            var dict: [String: String] = [:]
            for (key, color) in newValue {
                dict[key] = Self.encode(color)
            }
            if let data = try? JSONEncoder().encode(dict),
               let json = String(data: data, encoding: .utf8) {
                petalColorsRaw = json
            }
        }
    }
}
