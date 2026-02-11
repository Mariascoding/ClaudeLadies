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

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(opacity))
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
}
