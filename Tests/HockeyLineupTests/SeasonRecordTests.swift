import Foundation
import Testing
@testable import HockeyLineup

struct SeasonRecordTests {
    private func playedCard(_ result: MatchResult, isHome: Bool = true) -> LineupCard {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = isHome
        switch result {
        case .win: card.recordResult(ourScore: 3, opponentScore: 1)
        case .draw: card.recordResult(ourScore: 1, opponentScore: 1)
        case .loss: card.recordResult(ourScore: 0, opponentScore: 2)
        }
        return card
    }

    @Test func seasonRecordCountsEachResultType() {
        let cards = [playedCard(.win), playedCard(.win), playedCard(.draw), playedCard(.loss)]
        let record = cards.seasonRecord
        #expect(record.wins == 2)
        #expect(record.draws == 1)
        #expect(record.losses == 1)
        #expect(record.played == 4)
    }

    @Test func seasonRecordIgnoresLineupsWithoutAResult() {
        let cards = [playedCard(.win), LineupCard(formation: Formation.presets[0])]
        let record = cards.seasonRecord
        #expect(record.wins == 1)
        #expect(record.played == 1)
    }

    @Test func seasonRecordOfEmptyArrayIsAllZero() {
        let record = [LineupCard]().seasonRecord
        #expect(record == SeasonRecord(wins: 0, draws: 0, losses: 0))
    }
}
