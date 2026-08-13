import EventKit
import Foundation

/// Best-effort "Add to Calendar": creates a single event for a lineup's
/// fixture in the user's default calendar, with the venue as the location
/// and a reminder an hour before kickoff. Nothing else in the app depends
/// on this succeeding — access can be denied or a date can be unset.
enum CalendarService {
    enum CalendarServiceError: LocalizedError {
        case accessDenied
        case missingDate

        var errorDescription: String? {
            switch self {
            case .accessDenied: return "Calendar access was denied. Enable it in Settings to add fixtures."
            case .missingDate: return "Set a match date first."
            }
        }
    }

    @MainActor
    static func addFixtureToCalendar(for card: LineupCard) async throws {
        guard let matchDate = card.matchDate else { throw CalendarServiceError.missingDate }

        let store = EKEventStore()
        let granted = try await store.requestFullAccessToEvents()
        guard granted else { throw CalendarServiceError.accessDenied }

        let event = EKEvent(eventStore: store)
        event.title = card.opposition.isEmpty ? "\(MyTeam.name) Match" : "\(MyTeam.name) vs \(card.opposition)"
        event.startDate = matchDate
        event.endDate = matchDate.addingTimeInterval(90 * 60)
        if !card.venueText.isEmpty { event.location = card.venueText }
        event.notes = notes(for: card)
        event.calendar = store.defaultCalendarForNewEvents
        event.addAlarm(EKAlarm(relativeOffset: -60 * 60))

        try store.save(event, span: .thisEvent)
    }

    private static func notes(for card: LineupCard) -> String {
        var lines = [card.isHome ? "Home fixture" : "Away fixture"]
        if !card.coachName.isEmpty { lines.append("Coach: \(card.coachName)") }
        if !card.umpireOneName.isEmpty || !card.umpireTwoName.isEmpty {
            lines.append("Umpires: \([card.umpireOneName, card.umpireTwoName].filter { !$0.isEmpty }.joined(separator: ", "))")
        }
        return lines.joined(separator: "\n")
    }
}
