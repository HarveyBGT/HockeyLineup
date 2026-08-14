import Foundation
import UserNotifications

/// Best-effort local notification reminding you a lineup still needs
/// players, the evening before the match — nothing else in the app depends
/// on this succeeding, and it fails silently if notifications aren't
/// authorized. Scheduled/cancelled from `LineupStore` on every upsert and
/// delete, so it always tracks the lineup's current state.
enum MatchReminderScheduler {
    /// Whether a reminder is actually worth scheduling: the lineup isn't
    /// full yet, there's a match date to anchor to, and that reminder time
    /// hasn't already passed. Pulled out as a pure function so it's
    /// testable without touching `UNUserNotificationCenter`.
    static func shouldSchedule(for card: LineupCard, now: Date = Date()) -> Bool {
        guard !card.isPitchComplete, let reminderDate = card.reminderDate else { return false }
        return reminderDate > now
    }

    private static func identifier(for cardID: UUID) -> String { "lineup-reminder-\(cardID.uuidString)" }

    /// Cancels any existing reminder for this lineup, then schedules a
    /// fresh one if it's still needed — safe to call on every save.
    static func reschedule(for card: LineupCard) {
        let center = UNUserNotificationCenter.current()
        let id = identifier(for: card.id)
        center.removePendingNotificationRequests(withIdentifiers: [id])

        guard shouldSchedule(for: card), let reminderDate = card.reminderDate else { return }

        Task {
            guard let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge]), granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "Lineup not finished"
            let emptyCount = card.totalPitchCount - card.filledPitchCount
            let opponentText = card.opposition.isEmpty ? "your next match" : "vs \(card.opposition)"
            content.body = "\(emptyCount) spot\(emptyCount == 1 ? "" : "s") still need a player for \(opponentText) tomorrow."
            content.sound = .default

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            await withCheckedContinuation { continuation in
                center.add(request) { _ in continuation.resume() }
            }
        }
    }

    static func cancelReminder(for cardID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier(for: cardID)])
    }
}
