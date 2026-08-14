import Foundation
import Testing
@testable import HockeyLineup

struct MatchReminderSchedulerTests {
    private func fullyStaffedCard(matchDate: Date?) -> LineupCard {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        card.matchDate = matchDate
        for index in card.playerIDs.indices {
            card.assign(UUID(), to: .pitch(index))
        }
        return card
    }

    @Test func shouldNotScheduleWhenLineupIsAlreadyComplete() {
        let card = fullyStaffedCard(matchDate: Date().addingTimeInterval(86400 * 5))
        #expect(MatchReminderScheduler.shouldSchedule(for: card) == false)
    }

    @Test func shouldNotScheduleWithoutAMatchDate() {
        let card = LineupCard(formation: Formation.presets[0])
        #expect(MatchReminderScheduler.shouldSchedule(for: card) == false)
    }

    @Test func shouldScheduleWhenIncompleteAndReminderTimeIsInTheFuture() {
        var card = LineupCard(formation: Formation.presets[0])
        card.matchDate = Date().addingTimeInterval(86400 * 5) // 5 days out
        #expect(MatchReminderScheduler.shouldSchedule(for: card) == true)
    }

    @Test func shouldNotScheduleWhenReminderTimeHasAlreadyPassed() {
        var card = LineupCard(formation: Formation.presets[0])
        // Kickoff in an hour — "6pm the evening before" is already in the past.
        card.matchDate = Date().addingTimeInterval(3600)
        #expect(MatchReminderScheduler.shouldSchedule(for: card) == false)
    }
}
