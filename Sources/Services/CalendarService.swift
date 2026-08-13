import EventKit
import Foundation

/// The event details derived from a lineup card — pure data, no EventKit
/// dependency, so it's testable without calendar access.
struct FixtureEventDetails: Equatable {
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String
    var reminderOffset: TimeInterval
}

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

    /// The event that would be created for `card`, or nil if there's no
    /// match date to anchor it to.
    static func eventDetails(for card: LineupCard) -> FixtureEventDetails? {
        guard let matchDate = card.matchDate else { return nil }
        let title = card.opposition.isEmpty ? "\(MyTeam.name) Match" : "\(MyTeam.name) vs \(card.opposition)"
        return FixtureEventDetails(
            title: title,
            startDate: matchDate,
            endDate: matchDate.addingTimeInterval(90 * 60),
            location: card.venueText.isEmpty ? nil : card.venueText,
            notes: notes(for: card),
            reminderOffset: -60 * 60
        )
    }

    @MainActor
    static func addFixtureToCalendar(for card: LineupCard) async throws {
        guard let details = eventDetails(for: card) else { throw CalendarServiceError.missingDate }

        let store = EKEventStore()
        let granted = try await store.requestFullAccessToEvents()
        guard granted else { throw CalendarServiceError.accessDenied }

        let event = EKEvent(eventStore: store)
        event.title = details.title
        event.startDate = details.startDate
        event.endDate = details.endDate
        event.location = details.location
        event.notes = details.notes
        event.calendar = store.defaultCalendarForNewEvents
        event.addAlarm(EKAlarm(relativeOffset: details.reminderOffset))

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
