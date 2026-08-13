import Foundation
import Testing
@testable import HockeyLineup

struct PlayerAppearanceStatsTests {
    @Test func countsStartsAndBenchAppearancesAcrossCards() {
        let alice = Player(firstName: "Alice")
        let bob = Player(firstName: "Bob")
        let byID: [UUID: Player] = [alice.id: alice, bob.id: bob]

        var cardOne = LineupCard(formation: Formation.preset(id: "5-3-2"))
        cardOne.assign(alice.id, to: .pitch(0))
        cardOne.assign(bob.id, to: .bench(0))

        var cardTwo = LineupCard(formation: Formation.preset(id: "5-3-2"))
        cardTwo.assign(alice.id, to: .pitch(1))

        let stats = [cardOne, cardTwo].playerAppearanceStats { byID[$0] }

        let aliceStats = stats.first { $0.id == alice.id }
        #expect(aliceStats?.starts == 2)
        #expect(aliceStats?.benchAppearances == 0)
        #expect(aliceStats?.total == 2)

        let bobStats = stats.first { $0.id == bob.id }
        #expect(bobStats?.starts == 0)
        #expect(bobStats?.benchAppearances == 1)
    }

    @Test func sortsByTotalDescendingThenName() {
        let alice = Player(firstName: "Alice")
        let bob = Player(firstName: "Bob")
        let byID: [UUID: Player] = [alice.id: alice, bob.id: bob]

        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        card.assign(alice.id, to: .pitch(0))
        card.assign(bob.id, to: .pitch(1))

        let stats = [card].playerAppearanceStats { byID[$0] }
        // Tied totals (1 each) fall back to alphabetical order.
        #expect(stats.map(\.player.firstName) == ["Alice", "Bob"])
    }

    @Test func skipsPlayersTheLookupCannotResolve() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        card.assign(UUID(), to: .pitch(0))

        let stats = [card].playerAppearanceStats { _ in nil }
        #expect(stats.isEmpty)
    }

    @Test func emptyCardListProducesNoStats() {
        let stats = [LineupCard]().playerAppearanceStats { _ in nil }
        #expect(stats.isEmpty)
    }
}
