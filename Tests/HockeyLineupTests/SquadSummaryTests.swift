import Testing
@testable import HockeyLineup

struct SquadSummaryTests {
    @Test func squadSummaryCountsGoalkeepersAndPreferredRoles() {
        let players = [
            Player(firstName: "A", isGoalkeeper: true),
            Player(firstName: "B", preferredRole: .defense),
            Player(firstName: "C"),
        ]
        let summary = players.squadSummary
        #expect(summary.total == 3)
        #expect(summary.goalkeepers == 1)
        #expect(summary.withPreferredRole == 1)
    }

    @Test func squadSummaryOfEmptySquadIsAllZero() {
        let summary = [Player]().squadSummary
        #expect(summary == SquadSummary(total: 0, goalkeepers: 0, withPreferredRole: 0))
    }
}
