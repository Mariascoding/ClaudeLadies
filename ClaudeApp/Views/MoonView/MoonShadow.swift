//
//  MoonShadow.swift
//  LadiesApp
//
//  Created by Marta Maria Ries on 5/22/25.
//


import SwiftUI

struct MoonShadow: View {
    let currentMoonDay: Int
    let moonSize: CGFloat
    let blurRadius: CGFloat
    let opacity: Double

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Circle()
                .fill(shadowColor)
                .mask(
                    Circle()
                        .fill(Color.black)
                        .scaleEffect(
                            x: MoonUtils.shadowScale(for: currentMoonDay),
                            y: 1,
                            anchor: MoonUtils.anchorSide(for: currentMoonDay)
                        )
                )
        }
        .frame(width: moonSize, height: moonSize)
        .blur(radius: blurRadius)
    }

    private var shadowColor: Color {
        colorScheme == .dark
            ? Color.black.opacity(opacity)
            : Color(red: 0.62, green: 0.55, blue: 0.68).opacity(0.65)
    }
}
