import SwiftUI

struct DeviceLinkingCard: View {
    @Environment(HealthDataManager.self) private var healthManager

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "applewatch.and.arrow.forward")
                    .foregroundStyle(Color.appSage)
                Text("Health Devices")
                    .warmHeadline()
            }

            Text("Connect your devices to automatically track sleep, HRV, heart rate, temperature, and activity.")
                .captionStyle()
                .fixedSize(horizontal: false, vertical: true)

            ForEach(HealthDataSourceType.allCases) { source in
                sourceRow(source)
            }
        }
        .warmCard()
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    private func sourceRow(_ source: HealthDataSourceType) -> some View {
        let state = healthManager.connectionState(for: source)

        return HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: source.icon)
                .font(.title3)
                .foregroundStyle(iconColor(for: state))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(source.displayName)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)

                Text(statusText(for: state))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(statusColor(for: state))
            }

            Spacer()

            connectionButton(for: source, state: state)
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }

    @ViewBuilder
    private func connectionButton(for source: HealthDataSourceType, state: HealthConnectionState) -> some View {
        switch state {
        case .disconnected, .error:
            Button {
                Task {
                    try? await healthManager.connect(source: source)
                }
            } label: {
                Text("Connect")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(Color.appSage)
                    .clipShape(Capsule())
            }

        case .connecting:
            ProgressView()
                .controlSize(.small)

        case .connected:
            Button {
                healthManager.disconnect(source: source)
            } label: {
                Text("Disconnect")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown.opacity(0.5))
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(Color.appSoftBrown.opacity(0.08))
                    .clipShape(Capsule())
            }
        }
    }

    private func iconColor(for state: HealthConnectionState) -> Color {
        switch state {
        case .connected: Color.appSage
        case .error: Color.appRose
        default: Color.appSoftBrown.opacity(0.4)
        }
    }

    private func statusText(for state: HealthConnectionState) -> String {
        switch state {
        case .disconnected: "Not connected"
        case .connecting: "Connecting..."
        case .connected: "Connected"
        case .error(let msg): msg
        }
    }

    private func statusColor(for state: HealthConnectionState) -> Color {
        switch state {
        case .connected: Color.appSage
        case .error: Color.appRose
        default: Color.appSoftBrown.opacity(0.5)
        }
    }
}
