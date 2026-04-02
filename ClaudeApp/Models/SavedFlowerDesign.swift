import Foundation
import SwiftData

@Model
final class SavedFlowerDesign {
    var name: String
    var createdDate: Date

    // Design enums stored as raw strings
    var outerDesignRaw: String
    var innerDesignRaw: String
    var stamenDesignRaw: String
    var centerDesignRaw: String

    // Colors stored as FlowerColor raw strings
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

    init(
        name: String,
        outerDesign: OuterPetalDesign,
        innerDesign: InnerPetalDesign,
        stamenDesign: StamenDesign,
        centerDesign: CenterDesign,
        outerColor: FlowerColor,
        innerColor: FlowerColor,
        stamenColor: FlowerColor,
        centerColor: FlowerColor,
        geometry: FlowerGeometry
    ) {
        self.name = name
        self.createdDate = Date()
        self.outerDesignRaw = outerDesign.rawValue
        self.innerDesignRaw = innerDesign.rawValue
        self.stamenDesignRaw = stamenDesign.rawValue
        self.centerDesignRaw = centerDesign.rawValue
        self.outerColorRaw = outerColor.rawValue
        self.innerColorRaw = innerColor.rawValue
        self.stamenColorRaw = stamenColor.rawValue
        self.centerColorRaw = centerColor.rawValue
        self.outerCount = geometry.outerCount
        self.backCount = geometry.backCount
        self.innerCount = geometry.innerCount
        self.petalWidth = Double(geometry.petalWidth)
        self.innerWidth = Double(geometry.innerWidth)
        self.centerScale = Double(geometry.centerScale)
        self.stamenScale = Double(geometry.stamenScale)
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

    var outerColor: FlowerColor {
        get { FlowerColor(rawValue: outerColorRaw) ?? .rose }
        set { outerColorRaw = newValue.rawValue }
    }

    var innerColor: FlowerColor {
        get { FlowerColor(rawValue: innerColorRaw) ?? .terracotta }
        set { innerColorRaw = newValue.rawValue }
    }

    var stamenColor: FlowerColor {
        get { FlowerColor(rawValue: stamenColorRaw) ?? .golden }
        set { stamenColorRaw = newValue.rawValue }
    }

    var centerColor: FlowerColor {
        get { FlowerColor(rawValue: centerColorRaw) ?? .sage }
        set { centerColorRaw = newValue.rawValue }
    }

    var geometry: FlowerGeometry {
        FlowerGeometry(
            outerCount: outerCount,
            backCount: backCount,
            innerCount: innerCount,
            petalWidth: CGFloat(petalWidth),
            innerWidth: CGFloat(innerWidth),
            centerScale: CGFloat(centerScale),
            stamenScale: CGFloat(stamenScale)
        )
    }
}
