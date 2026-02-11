import SwiftUI

struct NourishNotificationCard: View {
    @Bindable var notificationManager: NourishNotificationManager
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "bell.fill")
                    .foregroundStyle(accentColor)
                Text("Reminders")
                    .warmHeadline()
            }

            switch notificationManager.permissionStatus {
            case .notDetermined:
                notDeterminedContent
            case .authorized:
                authorizedContent
            case .denied:
                deniedContent
            }
        }
        .warmCard()
    }

    // MARK: - Not Determined

    private var notDeterminedContent: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("Get gentle reminders for supplements, meals, and rituals at the right time of day.")
                .guidanceText()

            GentleButton("Enable Reminders", color: accentColor) {
                Task {
                    await notificationManager.requestPermission()
                }
            }
        }
    }

    // MARK: - Authorized

    private var authorizedContent: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            categoryToggle(
                icon: NutritionItemCategory.food.icon,
                name: NutritionItemCategory.food.displayName,
                isOn: Binding(
                    get: { notificationManager.foodNotificationsEnabled },
                    set: { notificationManager.foodNotificationsEnabled = $0 }
                )
            )

            categoryToggle(
                icon: NutritionItemCategory.supplement.icon,
                name: NutritionItemCategory.supplement.displayName,
                isOn: Binding(
                    get: { notificationManager.supplementNotificationsEnabled },
                    set: { notificationManager.supplementNotificationsEnabled = $0 }
                )
            )

            categoryToggle(
                icon: NutritionItemCategory.ritual.icon,
                name: NutritionItemCategory.ritual.displayName,
                isOn: Binding(
                    get: { notificationManager.ritualNotificationsEnabled },
                    set: { notificationManager.ritualNotificationsEnabled = $0 }
                )
            )
        }
    }

    private func categoryToggle(icon: String, name: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(accentColor)
                    .frame(width: 24)

                Text(name)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.appSoftBrown)
            }
        }
        .tint(accentColor)
    }

    // MARK: - Denied

    private var deniedContent: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("Notifications are turned off. Enable them in Settings to receive gentle reminders throughout the day.")
                .guidanceText()

            GentleOutlineButton("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}
