import Foundation
import UserNotifications

@Observable
final class NourishNotificationManager {

    // MARK: - Permission State

    enum PermissionStatus {
        case notDetermined
        case authorized
        case denied
    }

    private(set) var permissionStatus: PermissionStatus = .notDetermined

    // MARK: - Preferences (UserDefaults-backed)

    var foodNotificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "nourish_food_notifications") }
        set {
            UserDefaults.standard.set(newValue, forKey: "nourish_food_notifications")
            onPreferenceChanged?()
        }
    }

    var supplementNotificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "nourish_supplement_notifications") }
        set {
            UserDefaults.standard.set(newValue, forKey: "nourish_supplement_notifications")
            onPreferenceChanged?()
        }
    }

    var ritualNotificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "nourish_ritual_notifications") }
        set {
            UserDefaults.standard.set(newValue, forKey: "nourish_ritual_notifications")
            onPreferenceChanged?()
        }
    }

    var hasPromptedRituals: Bool {
        get { UserDefaults.standard.bool(forKey: "nourish_has_prompted_rituals") }
        set { UserDefaults.standard.set(newValue, forKey: "nourish_has_prompted_rituals") }
    }

    // MARK: - Callback

    var onPreferenceChanged: (() -> Void)?

    // MARK: - Permission

    func checkPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            switch settings.authorizationStatus {
            case .notDetermined:
                permissionStatus = .notDetermined
            case .authorized, .provisional, .ephemeral:
                permissionStatus = .authorized
            case .denied:
                permissionStatus = .denied
            @unknown default:
                permissionStatus = .denied
            }
        }
    }

    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            await checkPermissionStatus()
            return granted
        } catch {
            await checkPermissionStatus()
            return false
        }
    }

    // MARK: - Scheduling

    func rescheduleNotifications(plan: DailyNutritionPlan, completedItemIDs: Set<String>) {
        let center = UNUserNotificationCenter.current()

        // Cancel all existing nourish notifications
        center.getPendingNotificationRequests { requests in
            let nourishIDs = requests
                .filter { $0.identifier.hasPrefix("nourish_") }
                .map(\.identifier)
            center.removePendingNotificationRequests(withIdentifiers: nourishIDs)

            // Schedule new ones on a background queue
            self.scheduleItems(plan: plan, completedItemIDs: completedItemIDs)
        }
    }

    // MARK: - Private Scheduling

    private func scheduleItems(plan: DailyNutritionPlan, completedItemIDs: Set<String>) {
        let now = Date()
        let calendar = Calendar.current

        // Track stagger offsets per category+timeblock
        var staggerCounts: [String: Int] = [:]

        for block in plan.timeBlocks {
            for item in block.allItems {
                guard shouldNotify(for: item.category) else { continue }
                guard !completedItemIDs.contains(item.id) else { continue }

                let staggerKey = "\(item.category.rawValue)_\(item.timeBlock.rawValue)"
                let staggerIndex = staggerCounts[staggerKey, default: 0]
                staggerCounts[staggerKey] = staggerIndex + 1

                let baseTime = notificationTime(for: item.category, timeOfDay: item.timeBlock)
                let staggerMinutes = staggerIndex * 2

                var components = calendar.dateComponents([.year, .month, .day], from: now)
                components.hour = baseTime.hour
                components.minute = baseTime.minute + staggerMinutes

                // Skip if time has already passed today
                if let fireDate = calendar.date(from: components), fireDate <= now {
                    continue
                }

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: DateComponents(hour: components.hour, minute: components.minute),
                    repeats: false
                )

                let content = UNMutableNotificationContent()
                content.title = notificationTitle(for: item)
                content.body = notificationBody(for: item)
                content.sound = .default

                let request = UNNotificationRequest(
                    identifier: "nourish_\(item.id)",
                    content: content,
                    trigger: trigger
                )

                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    private func shouldNotify(for category: NutritionItemCategory) -> Bool {
        switch category {
        case .food: return foodNotificationsEnabled
        case .supplement: return supplementNotificationsEnabled
        case .ritual: return ritualNotificationsEnabled
        }
    }

    // MARK: - Time Mapping

    private struct TimeComponents {
        let hour: Int
        let minute: Int
    }

    private func notificationTime(for category: NutritionItemCategory, timeOfDay: TimeOfDay) -> TimeComponents {
        switch (category, timeOfDay) {
        // Supplements — before meals
        case (.supplement, .morning):   return TimeComponents(hour: 6, minute: 30)
        case (.supplement, .afternoon): return TimeComponents(hour: 11, minute: 30)
        case (.supplement, .evening):   return TimeComponents(hour: 17, minute: 30)
        // Foods — at mealtimes
        case (.food, .morning):         return TimeComponents(hour: 7, minute: 30)
        case (.food, .afternoon):       return TimeComponents(hour: 12, minute: 30)
        case (.food, .evening):         return TimeComponents(hour: 18, minute: 30)
        // Rituals — in between
        case (.ritual, .morning):       return TimeComponents(hour: 10, minute: 0)
        case (.ritual, .afternoon):     return TimeComponents(hour: 15, minute: 0)
        case (.ritual, .evening):       return TimeComponents(hour: 21, minute: 0)
        }
    }

    // MARK: - Notification Content

    private func notificationTitle(for item: NutritionItem) -> String {
        switch (item.category, item.timeBlock) {
        case (.supplement, .morning):   return "Before breakfast"
        case (.supplement, .afternoon): return "Before lunch"
        case (.supplement, .evening):   return "Before dinner"
        case (.food, .morning):         return "Breakfast nourishment"
        case (.food, .afternoon):       return "Lunchtime nourishment"
        case (.food, .evening):         return "Dinner nourishment"
        case (.ritual, .morning):       return "Your morning ritual"
        case (.ritual, .afternoon):     return "Your afternoon ritual"
        case (.ritual, .evening):       return "Your evening ritual"
        }
    }

    private func notificationBody(for item: NutritionItem) -> String {
        switch item.category {
        case .supplement:
            return "A gentle reminder for your \(item.name)"
        case .food:
            return item.name
        case .ritual:
            return item.name
        }
    }
}
