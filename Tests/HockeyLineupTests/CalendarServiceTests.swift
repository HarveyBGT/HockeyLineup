import Foundation
import Testing
@testable import HockeyLineup

struct CalendarServiceTests {
    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 14) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return Calendar.current.date(from: components) ?? Date()
    }

    @Test func eventDetailsIsNilWithoutAMatchDate() {
        let card = LineupCard(formation: Formation.presets[0])
        #expect(CalendarService.eventDetails(for: card) == nil)
    }

    @Test func eventDetailsTitleIncludesOppositionWhenSet() {
        var card = LineupCard(formation: Formation.presets[0])
        card.opposition = "Cheam M1"
        card.matchDate = date(2026, 10, 10)
        #expect(CalendarService.eventDetails(for: card)?.title == "\(MyTeam.name) vs Cheam M1")
    }

    @Test func eventDetailsTitleFallsBackWhenOppositionIsEmpty() {
        var card = LineupCard(formation: Formation.presets[0])
        card.matchDate = date(2026, 10, 10)
        #expect(CalendarService.eventDetails(for: card)?.title == "\(MyTeam.name) Match")
    }

    @Test func eventDetailsEndDateIsNinetyMinutesAfterKickoff() {
        var card = LineupCard(formation: Formation.presets[0])
        let kickoff = date(2026, 10, 10)
        card.matchDate = kickoff
        let details = CalendarService.eventDetails(for: card)
        #expect(details?.startDate == kickoff)
        #expect(details?.endDate == kickoff.addingTimeInterval(90 * 60))
    }

    @Test func eventDetailsReminderIsOneHourBeforeKickoff() {
        var card = LineupCard(formation: Formation.presets[0])
        card.matchDate = date(2026, 10, 10)
        let expectedOffset: TimeInterval = -3600
        #expect(CalendarService.eventDetails(for: card)?.reminderOffset == expectedOffset)
    }

    @Test func eventDetailsLocationIsNilWhenVenueTextIsEmpty() {
        var card = LineupCard(formation: Formation.presets[0])
        card.matchDate = date(2026, 10, 10)
        card.isHome = false // no curated venue for an empty opposition name
        #expect(CalendarService.eventDetails(for: card)?.location == nil)
    }

    @Test func eventDetailsLocationUsesVenueTextForAHomeFixture() {
        var card = LineupCard(formation: Formation.presets[0])
        card.matchDate = date(2026, 10, 10)
        card.isHome = true
        #expect(CalendarService.eventDetails(for: card)?.location == card.venueText)
    }

    @Test func eventDetailsNotesIncludeHomeOrAwayAndCoachAndUmpires() {
        var card = LineupCard(formation: Formation.presets[0])
        card.matchDate = date(2026, 10, 10)
        card.isHome = true
        card.coachName = "Sam Coach"
        card.umpireOneName = "Umpire A"
        card.umpireTwoName = ""

        let notes = CalendarService.eventDetails(for: card)?.notes ?? ""
        #expect(notes.contains("Home fixture"))
        #expect(notes.contains("Coach: Sam Coach"))
        #expect(notes.contains("Umpires: Umpire A"))
    }

    @Test func eventDetailsNotesOmitCoachAndUmpiresWhenUnset() {
        var card = LineupCard(formation: Formation.presets[0])
        card.matchDate = date(2026, 10, 10)
        card.isHome = false

        let notes = CalendarService.eventDetails(for: card)?.notes ?? ""
        #expect(notes == "Away fixture")
    }
}
