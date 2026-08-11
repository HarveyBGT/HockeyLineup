import Foundation
import Testing
@testable import HockeyLineup

struct LineupCardTests {
    @Test func conformPlayerIDsToFormationGrowsArray() {
        var card = LineupCard(formation: Formation.preset(id: "3-4-3"))
        card.formationID = "4-2-4"
        card.conformPlayerIDsToFormation()
        #expect(card.playerIDs.count == Formation.preset(id: "4-2-4").positions.count)
    }

    @Test func conformPlayerIDsToFormationShrinksArray() {
        var card = LineupCard(formation: Formation.preset(id: "2-3-5"))
        card.playerIDs = card.playerIDs.map { _ in UUID() }
        card.formationID = "5-3-2"
        card.conformPlayerIDsToFormation()
        #expect(card.playerIDs.count == Formation.preset(id: "5-3-2").positions.count)
    }

    @Test func activeColorReflectsHomeAwayToggle() {
        var card = LineupCard(formation: Formation.presets[0])
        card.homeColorHex = "#111111"
        card.awayColorHex = "#EEEEEE"

        card.isHome = true
        #expect(card.activeColorHex == "#111111")

        card.isHome = false
        #expect(card.activeColorHex == "#EEEEEE")
    }

    @Test func matchSummaryTextIsEmptyWithNothingSet() {
        let card = LineupCard(formation: Formation.presets[0])
        #expect(card.matchSummaryText.isEmpty)
    }

    @Test func matchSummaryTextIncludesOppositionAndVenue() {
        var card = LineupCard(formation: Formation.presets[0])
        card.opposition = "Old Tonbridgians M1"
        card.isHome = true
        #expect(card.matchSummaryText == "vs Old Tonbridgians M1 — Home")
    }

    /// The exact scenario that has bitten this app repeatedly: a lineup saved
    /// before `benchPlayerIDs`/`coachName`/umpire fields existed must still
    /// decode successfully, falling back to defaults instead of wiping data.
    @Test func decodesJSONMissingNewerFieldsWithoutThrowing() throws {
        let oldShapeJSON = """
        {
            "id": "\(UUID().uuidString)",
            "clubName": "Barnes M3",
            "opposition": "Cheam M1",
            "isHome": true,
            "formationID": "5-3-2",
            "playerIDs": [null, null, null],
            "homeColorHex": "#1C63A8",
            "awayColorHex": "#FFFFFF",
            "createdAt": "2026-01-01T00:00:00Z",
            "updatedAt": "2026-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let card = try decoder.decode(LineupCard.self, from: oldShapeJSON)

        #expect(card.opposition == "Cheam M1")
        #expect(card.benchPlayerIDs.count == 5)
        #expect(card.benchPlayerIDs.allSatisfy { $0 == nil })
        #expect(card.coachName.isEmpty)
        #expect(card.umpireOneName.isEmpty)
        #expect(card.umpireTwoName.isEmpty)
    }

    @Test func decodesCompletelyEmptyJSONObjectWithAllDefaults() throws {
        let data = "{}".data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let card = try decoder.decode(LineupCard.self, from: data)

        #expect(card.opposition.isEmpty)
        #expect(card.isHome == true)
        #expect(card.formationID == Formation.presets[0].id)
    }
}
