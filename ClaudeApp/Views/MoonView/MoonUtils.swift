//
//  MoonUtils.swift
//  LadiesApp
//
//  Created by Marta Maria Ries on 5/22/25.
//


import SwiftUI

struct MoonUtils {
    /// Returns the illuminated percentage of the moon (0 = new moon, 1 = full moon)
    static func illumination(for day: Int) -> CGFloat {
        let angle = 2 * .pi * CGFloat(day % 30) / 30.0
        return 0.5 * (1 - cos(angle))
    }

    /// Returns the amount of shadow left (1 = full dark, 0 = fully lit)
    static func shadowScale(for day: Int) -> CGFloat {
        max(1.0 - illumination(for: day), 0.0)
    }

    /// Determines which side the shadow is anchored to
    static func anchorSide(for day: Int) -> UnitPoint {
        day % 30 <= 15 ? .trailing : .leading
    }
}


