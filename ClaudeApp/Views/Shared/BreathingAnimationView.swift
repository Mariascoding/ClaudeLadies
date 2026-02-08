import SwiftUI

struct BreathingAnimationView: View {
    let exercise: BreathworkExercise
    @State private var isExpanded = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var currentRound = 1
    @State private var isActive = false

    private enum BreathPhase: String {
        case inhale = "Breathe in"
        case hold = "Hold"
        case exhale = "Breathe out"
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text(exercise.name)
                .warmHeadline()

            ZStack {
                Circle()
                    .fill(Color.appSage.opacity(0.15))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(Color.appSage.opacity(0.3))
                    .frame(width: isExpanded ? 140 : 60, height: isExpanded ? 140 : 60)
                    .animation(.easeInOut(duration: currentDuration), value: isExpanded)

                VStack(spacing: 4) {
                    Text(breathPhase.rawValue)
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.appSoftBrown)

                    if isActive {
                        Text("Round \(currentRound)/\(exercise.rounds)")
                            .captionStyle()
                    }
                }
            }

            Text(exercise.instruction)
                .guidanceText()
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if !isActive {
                GentleButton("Begin", color: .appSage) {
                    startBreathing()
                }
            } else {
                GentleOutlineButton("Stop") {
                    stopBreathing()
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.md)
    }

    private var currentDuration: Double {
        switch breathPhase {
        case .inhale: Double(exercise.inhaleSeconds)
        case .hold: Double(exercise.holdSeconds)
        case .exhale: Double(exercise.exhaleSeconds)
        }
    }

    private func startBreathing() {
        isActive = true
        currentRound = 1
        runBreathCycle()
    }

    private func stopBreathing() {
        isActive = false
        isExpanded = false
        breathPhase = .inhale
    }

    private func runBreathCycle() {
        guard isActive else { return }

        // Inhale
        breathPhase = .inhale
        isExpanded = true

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(exercise.inhaleSeconds)) {
            guard self.isActive else { return }

            if exercise.holdSeconds > 0 {
                // Hold
                self.breathPhase = .hold
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(exercise.holdSeconds)) {
                    self.startExhale()
                }
            } else {
                self.startExhale()
            }
        }
    }

    private func startExhale() {
        guard isActive else { return }
        breathPhase = .exhale
        isExpanded = false

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(exercise.exhaleSeconds)) {
            guard self.isActive else { return }
            if self.currentRound < exercise.rounds {
                self.currentRound += 1
                self.runBreathCycle()
            } else {
                self.stopBreathing()
            }
        }
    }
}
