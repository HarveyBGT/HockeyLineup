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

    // MARK: - Match detail text for the shareable card

    @Test func dateAndKickoffTimeTextsAreEmptyWithNoDateSet() {
        let card = LineupCard(formation: Formation.presets[0])
        #expect(card.matchDateText.isEmpty)
        #expect(card.kickoffTimeText.isEmpty)
    }

    @Test func dateAndKickoffTimeTextsFormatSeparately() {
        var card = LineupCard(formation: Formation.presets[0])
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 19
        components.hour = 14
        components.minute = 30
        card.matchDate = Calendar.current.date(from: components)

        #expect(card.matchDateText.contains("19"))
        #expect(card.kickoffTimeText == "14:30")
    }

    @Test func venueTextUsesBarnesGroundWhenHome() {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = true
        card.pitchVenueID = "barnes"
        #expect(card.venueText == "Dukes Meadow, Chiswick, W4")
    }

    @Test func venueTextIsEmptyForClassicGreenPitch() {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = true
        card.pitchVenueID = PitchVenue.classicGreen.id
        #expect(card.venueText.isEmpty)
    }

    @Test func venueTextUsesRealGroundForACuratedAwayOpponent() {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = false
        card.opposition = "Cheam M1"
        card.pitchVenueID = "barnes" // stale value from a previous home game
        #expect(card.venueText == "Cheam Sports Club, Sutton, SM2 7BJ")
    }

    @Test func venueTextFallsBackToOpponentNameWhenAwayAndUncurated() {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = false
        card.opposition = "Some Made Up Club M1"
        #expect(card.venueText == "Some Made Up Club M1's ground")
    }

    @Test func venueTextIsEmptyWhenAwayWithNoOpponentSet() {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = false
        card.opposition = ""
        #expect(card.venueText.isEmpty)
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

    // MARK: - assign(_:to:) / slot(of:)

    @Test func assigningAPlayerToAnEmptySlotJustPlacesThem() {
        var card = LineupCard(formation: Formation.presets[0])
        let player = UUID()
        card.assign(player, to: .pitch(0))
        #expect(card.playerIDs[0] == player)
        #expect(card.slot(of: player) == .pitch(0))
    }

    @Test func reassigningAPlayerToANewPitchSlotVacatesTheOldOne() {
        var card = LineupCard(formation: Formation.presets[0])
        let player = UUID()
        card.assign(player, to: .pitch(0))
        card.assign(player, to: .pitch(3))

        #expect(card.playerIDs[0] == nil)
        #expect(card.playerIDs[3] == player)
        #expect(card.allAssignedPlayerIDs == [player])
    }

    @Test func movingAPlayerFromBenchToPitchClearsTheBenchSlot() {
        var card = LineupCard(formation: Formation.presets[0])
        let player = UUID()
        card.assign(player, to: .bench(2))
        card.assign(player, to: .pitch(5))

        #expect(card.benchPlayerIDs[2] == nil)
        #expect(card.playerIDs[5] == player)
        #expect(card.slot(of: player) == .pitch(5))
    }

    @Test func assigningAPlayerAlreadyInTheTargetSlotIsANoOp() {
        var card = LineupCard(formation: Formation.presets[0])
        let player = UUID()
        card.assign(player, to: .pitch(1))
        card.assign(player, to: .pitch(1))
        #expect(card.playerIDs[1] == player)
        #expect(card.allAssignedPlayerIDs.count == 1)
    }

    /// The core invariant: no player should ever be placed in two slots.
    /// Picking an already-placed player for a new slot is how swapping and
    /// replacing works — it should never result in a duplicate.
    @Test func aPlayerCanNeverOccupyTwoSlotsAtOnce() {
        var card = LineupCard(formation: Formation.presets[0])
        let playerA = UUID()
        let playerB = UUID()

        card.assign(playerA, to: .pitch(0))
        card.assign(playerB, to: .pitch(1))
        card.assign(playerA, to: .bench(0)) // move A to the bench

        let allSlots = card.playerIDs + card.benchPlayerIDs
        #expect(allSlots.compactMap { $0 }.filter { $0 == playerA }.count == 1)
        #expect(card.allAssignedPlayerIDs == [playerA, playerB])
    }

    @Test func clearingASlotWithNilRemovesThePlayer() {
        var card = LineupCard(formation: Formation.presets[0])
        let player = UUID()
        card.assign(player, to: .pitch(2))
        card.assign(nil, to: .pitch(2))
        #expect(card.playerIDs[2] == nil)
        #expect(card.slot(of: player) == nil)
    }

    @Test func unplacedPlayerHasNoSlot() {
        let card = LineupCard(formation: Formation.presets[0])
        #expect(card.slot(of: UUID()) == nil)
    }

    // MARK: - swapOrMove(from:to:) — drag-and-drop

    @Test func swapOrMoveExchangesTwoOccupiedSlots() {
        var card = LineupCard(formation: Formation.presets[0])
        let playerA = UUID()
        let playerB = UUID()
        card.assign(playerA, to: .pitch(0))
        card.assign(playerB, to: .pitch(1))

        card.swapOrMove(from: .pitch(0), to: .pitch(1))

        #expect(card.playerIDs[0] == playerB)
        #expect(card.playerIDs[1] == playerA)
        #expect(card.allAssignedPlayerIDs == [playerA, playerB])
    }

    @Test func swapOrMoveIntoAnEmptySlotJustMovesThePlayer() {
        var card = LineupCard(formation: Formation.presets[0])
        let player = UUID()
        card.assign(player, to: .pitch(0))

        card.swapOrMove(from: .pitch(0), to: .bench(2))

        #expect(card.playerIDs[0] == nil)
        #expect(card.benchPlayerIDs[2] == player)
    }

    @Test func swapOrMoveBetweenPitchAndBenchTradesPlaces() {
        var card = LineupCard(formation: Formation.presets[0])
        let pitchPlayer = UUID()
        let benchPlayer = UUID()
        card.assign(pitchPlayer, to: .pitch(4))
        card.assign(benchPlayer, to: .bench(1))

        card.swapOrMove(from: .bench(1), to: .pitch(4))

        #expect(card.playerIDs[4] == benchPlayer)
        #expect(card.benchPlayerIDs[1] == pitchPlayer)
    }

    @Test func swapOrMoveToItselfIsANoOp() {
        var card = LineupCard(formation: Formation.presets[0])
        let player = UUID()
        card.assign(player, to: .pitch(3))
        card.swapOrMove(from: .pitch(3), to: .pitch(3))
        #expect(card.playerIDs[3] == player)
    }

    @Test func slotDragPayloadRoundTrips() {
        #expect(PlayerSlot(dragPayload: PlayerSlot.pitch(7).dragPayload) == .pitch(7))
        #expect(PlayerSlot(dragPayload: PlayerSlot.bench(2).dragPayload) == .bench(2))
        #expect(PlayerSlot(dragPayload: "garbage") == nil)
        #expect(PlayerSlot(dragPayload: "pitch:notanumber") == nil)
    }

    // MARK: - Match result

    @Test func resultAndScoreTextAreNilUntilBothScoresAreSet() {
        var card = LineupCard(formation: Formation.presets[0])
        #expect(card.result == nil)
        #expect(card.scoreText == nil)

        card.homeScore = 3
        #expect(card.result == nil, "one-sided score shouldn't produce a result")

        card.awayScore = 1
        #expect(card.result != nil)
    }

    @Test func resultIsFromOurPerspectiveWhenHome() {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = true
        card.homeScore = 3
        card.awayScore = 1
        #expect(card.result == .win)
        #expect(card.scoreText == "3 - 1")

        card.homeScore = 1
        card.awayScore = 3
        #expect(card.result == .loss)

        card.homeScore = 2
        card.awayScore = 2
        #expect(card.result == .draw)
    }

    @Test func resultIsFromOurPerspectiveWhenAway() {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = false
        card.homeScore = 1
        card.awayScore = 3
        // We're the away team, so 3-1 in our favour is a win despite the
        // higher number sitting in "homeScore".
        #expect(card.result == .win)

        card.homeScore = 3
        card.awayScore = 1
        #expect(card.result == .loss)
    }

    @Test func decodesLineupCardJSONMissingScores() throws {
        let data = "{}".data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let card = try decoder.decode(LineupCard.self, from: data)
        #expect(card.homeScore == nil)
        #expect(card.awayScore == nil)
        #expect(card.result == nil)
    }

    // MARK: - recordResult

    @Test func recordResultMapsOurScoreToHomeScoreWhenHome() {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = true
        card.recordResult(ourScore: 4, opponentScore: 2)
        #expect(card.homeScore == 4)
        #expect(card.awayScore == 2)
    }

    @Test func recordResultMapsOurScoreToAwayScoreWhenAway() {
        var card = LineupCard(formation: Formation.presets[0])
        card.isHome = false
        card.recordResult(ourScore: 4, opponentScore: 2)
        #expect(card.homeScore == 2)
        #expect(card.awayScore == 4)
    }

    // MARK: - placementLabel

    @Test func placementLabelIsNilWhenPlayerIsInTheExcludedSlot() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        let playerID = UUID()
        card.assign(playerID, to: .pitch(2))
        #expect(card.placementLabel(for: playerID, excluding: .pitch(2)) == nil)
    }

    @Test func placementLabelDescribesAPitchPositionWithItsRole() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        let playerID = UUID()
        card.assign(playerID, to: .pitch(0)) // goalkeeper slot
        #expect(card.placementLabel(for: playerID, excluding: .bench(0)) == "On pitch — GK")
    }

    @Test func placementLabelDescribesTheBench() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        let playerID = UUID()
        card.assign(playerID, to: .bench(1))
        #expect(card.placementLabel(for: playerID, excluding: .pitch(0)) == "On bench")
    }

    @Test func placementLabelIsNilWhenPlayerIsNotPlacedAnywhere() {
        let card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        #expect(card.placementLabel(for: UUID(), excluding: .pitch(0)) == nil)
    }

    // MARK: - Pitch completeness

    @Test func freshLineupIsNotPitchComplete() {
        let card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        #expect(card.filledPitchCount == 0)
        #expect(card.totalPitchCount == 11)
        #expect(card.isPitchComplete == false)
    }

    @Test func lineupIsPitchCompleteOnlyWhenEveryPositionIsFilled() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        for index in card.playerIDs.indices {
            card.assign(UUID(), to: .pitch(index))
        }
        #expect(card.filledPitchCount == 11)
        #expect(card.isPitchComplete == true)

        card.assign(nil, to: .pitch(0))
        #expect(card.isPitchComplete == false)
    }

    @Test func benchAssignmentsDoNotCountTowardsPitchCompleteness() {
        var card = LineupCard(formation: Formation.preset(id: "5-3-2"))
        card.assign(UUID(), to: .bench(0))
        #expect(card.filledPitchCount == 0)
        #expect(card.isPitchComplete == false)
    }

    // MARK: - reminderDate

    @Test func reminderDateIsSixPmTheDayBeforeKickoff() {
        var card = LineupCard(formation: Formation.presets[0])
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 19
        components.hour = 14
        let kickoff = Calendar.current.date(from: components)!
        card.matchDate = kickoff

        let reminder = card.reminderDate
        #expect(reminder != nil)
        let reminderComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder ?? kickoff)
        #expect(reminderComponents.year == 2026)
        #expect(reminderComponents.month == 9)
        #expect(reminderComponents.day == 18)
        #expect(reminderComponents.hour == 18)
        #expect(reminderComponents.minute == 0)
    }

    @Test func reminderDateIsNilWithoutAMatchDate() {
        let card = LineupCard(formation: Formation.presets[0])
        #expect(card.reminderDate == nil)
    }
}
