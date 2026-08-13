import Foundation
import Testing
@testable import HockeyLineup

struct LineupAutoFillerTests {
    private func player(_ name: String, number: Int? = nil, isGoalkeeper: Bool = false, preferredRole: PositionRole? = nil) -> Player {
        Player(firstName: name, squadNumber: number, isGoalkeeper: isGoalkeeper, preferredRole: preferredRole)
    }

    @Test func unassignedSquadSortsNumberedPlayersFirstByNumber() {
        let card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        let squad = [player("Charlie", number: 7), player("Alice"), player("Bob", number: 3)]
        let result = LineupAutoFiller.unassignedSquad(squad, notIn: card)
        #expect(result.map(\.firstName) == ["Bob", "Charlie", "Alice"])
    }

    @Test func unassignedSquadExcludesPlayersAlreadyPlaced() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        let placed = player("Placed")
        let bench = player("Benched")
        let free = player("Free")
        card.assign(placed.id, to: .pitch(0))
        card.assign(bench.id, to: .bench(0))

        let result = LineupAutoFiller.unassignedSquad([placed, bench, free], notIn: card)
        #expect(result.map(\.firstName) == ["Free"])
    }

    @Test func fillPrefersPlayerWithMatchingPreferredRoleForGoalkeeperSlot() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        let squad = [
            player("NotAKeeper"),
            player("PreferredKeeper", preferredRole: .goalkeeper),
        ]
        LineupAutoFiller.fill(&card, from: squad)
        #expect(card.playerIDs[0] == squad[1].id)
    }

    @Test func fillFallsBackToIsGoalkeeperFlagWhenNoPreferredRoleMatch() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        let squad = [
            player("FieldPlayer"),
            player("FlaggedKeeper", isGoalkeeper: true),
        ]
        LineupAutoFiller.fill(&card, from: squad)
        #expect(card.playerIDs[0] == squad[1].id)
    }

    @Test func fillSkipsPlayersAlreadyPlacedElsewhereInTheCard() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        let alreadyOnBench = player("OnBench")
        let free = player("Free", preferredRole: .goalkeeper)
        card.assign(alreadyOnBench.id, to: .bench(0))

        LineupAutoFiller.fill(&card, from: [alreadyOnBench, free])
        #expect(card.playerIDs[0] == free.id)
        // The already-placed player should still be on the bench, not moved.
        #expect(card.benchPlayerIDs[0] == alreadyOnBench.id)
    }

    @Test func fillStopsGracefullyWhenSquadIsSmallerThanTheFormation() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2")) // 11 pitch slots
        let squad = [player("Only One")]
        LineupAutoFiller.fill(&card, from: squad)
        #expect(card.playerIDs.compactMap { $0 }.count == 1)
        #expect(card.playerIDs[0] == squad[0].id)
    }

    @Test func bestCandidateIndexReturnsZeroWhenRoleIsNil() {
        let pool = [Player(firstName: "A"), Player(firstName: "B")]
        #expect(LineupAutoFiller.bestCandidateIndex(in: pool, for: nil) == 0)
    }

    @Test func bestCandidateIndexPrefersNoPreferenceOverAConflictingExplicitPreference() {
        let striker = player("Striker", preferredRole: .forward)
        let utility = player("Utility")
        let pool = [striker, utility]
        // Nobody prefers or is flagged for goalkeeper — should pick the
        // no-preference player rather than displacing the striker.
        let index = LineupAutoFiller.bestCandidateIndex(in: pool, for: .goalkeeper)
        #expect(pool[index].firstName == "Utility")
    }

    @Test func bestCandidateIndexFallsBackToPickOrderWhenEveryoneHasAConflictingPreference() {
        let striker = player("Striker", preferredRole: .forward)
        let defender = player("Defender", preferredRole: .defense)
        let pool = [striker, defender]
        #expect(LineupAutoFiller.bestCandidateIndex(in: pool, for: .goalkeeper) == 0)
    }

    @Test func fillAvoidsPuttingAPlayerWithADifferentExplicitPreferenceInGoal() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        let striker = player("Striker", preferredRole: .forward)
        let utility = player("Utility")
        LineupAutoFiller.fill(&card, from: [striker, utility])
        #expect(card.playerIDs[0] == utility.id)
    }
}
