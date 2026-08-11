import Testing
@testable import HockeyLineup

struct FormationTests {
    @Test func everyPresetHasElevenPlayersIncludingGoalkeeper() {
        for formation in Formation.presets {
            #expect(formation.positions.count == 11, "\(formation.name) should field 11 players")
            #expect(formation.positions.filter { $0.role == .goalkeeper }.count == 1, "\(formation.name) should have exactly one GK")
        }
    }

    @Test func presetIDsAreUnique() {
        let ids = Formation.presets.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func presetLookupFallsBackToFirstForUnknownID() {
        let formation = Formation.preset(id: "not-a-real-formation")
        #expect(formation.id == Formation.presets[0].id)
    }

    @Test func positionIDsAreSequentialFromZero() {
        for formation in Formation.presets {
            let ids = formation.positions.map(\.id).sorted()
            #expect(ids == Array(0..<formation.positions.count))
        }
    }

    @Test func diamondFormationKeepsFourMidfieldersAndDefenders() {
        let diamond = Formation.preset(id: "4-4-2-diamond")
        #expect(diamond.positions.filter { $0.role == .defense }.count == 4)
        #expect(diamond.positions.filter { $0.role == .midfield }.count == 4)
        #expect(diamond.positions.filter { $0.role == .forward }.count == 2)
    }
}
