//
//  MoonState.swift
//  LadiesApp
//
//  Created by Marta Maria Ries on 12/15/25.
//


import SwiftUI

@MainActor
final class MoonState: ObservableObject {

    @Published var moonPhase: Double = 0.0
    @Published var isLoaded: Bool = false   // 👈 key

    var moonDay: Int {
        Int(moonPhase * 29.53)
    }

    func load() async {
        do {
            // ⚠️ replace with your actual fetch implementation
            moonPhase = try await MoonService.shared.fetchMoonPhase(
                latitude: 47.3769,
                longitude: 8.5417
            )

            withAnimation(.easeInOut(duration: 0.8)) {
                isLoaded = true
            }
        } catch {
            print("🌙 Moon fetch failed:", error)
        }
    }
}
