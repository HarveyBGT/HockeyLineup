import Foundation
import Testing
@testable import HockeyLineup

struct PlayerTests {
    @Test func fullNameJoinsFirstAndLastSkippingEmpty() {
        var player = Player()
        player.firstName = "Harvey"
        player.lastName = ""
        #expect(player.fullName == "Harvey")

        player.lastName = "Terry"
        #expect(player.fullName == "Harvey Terry")
    }

    @Test func captaincyBadgeMatchesRole() {
        var player = Player()
        player.captaincy = .none
        #expect(player.captaincyBadge == nil)

        player.captaincy = .captain
        #expect(player.captaincyBadge == "C")

        player.captaincy = .viceCaptain
        #expect(player.captaincyBadge == "VC")
    }

    /// The default hairstyle (`.short`) was the one hit by the invisible-hair
    /// bug reported earlier — pin its default so a regression there is caught.
    @Test func newPlayerAvatarDefaultsToShortHairNoBeardNoGlasses() {
        let avatar = PlayerAvatar()
        #expect(avatar.hairStyle == .short)
        #expect(avatar.beardStyle == .none)
        #expect(avatar.wearsGlasses == false)
    }

    /// A player saved before the `beardStyle` trait existed must still decode,
    /// defaulting the new trait to `.none` rather than failing the squad load.
    @Test func decodesPlayerJSONMissingBeardStyle() throws {
        let oldShapeJSON = """
        {
            "id": "\(UUID().uuidString)",
            "firstName": "Ben",
            "lastName": "Hughes",
            "isGoalkeeper": false,
            "captaincy": "captain",
            "avatar": {
                "skinToneHex": "#EAC1A0",
                "hairStyle": "curly",
                "hairColorHex": "#0B0B0B",
                "wearsGlasses": true
            }
        }
        """.data(using: .utf8)!

        let player = try JSONDecoder().decode(Player.self, from: oldShapeJSON)
        #expect(player.fullName == "Ben Hughes")
        #expect(player.avatar.hairStyle == .curly)
        #expect(player.avatar.wearsGlasses == true)
        #expect(player.avatar.beardStyle == .none)
    }

    @Test func newPlayerHasNoPreferredRoleByDefault() {
        #expect(Player().preferredRole == nil)
    }

    /// A player saved before `preferredRole` existed must still decode.
    @Test func decodesPlayerJSONMissingPreferredRole() throws {
        let oldShapeJSON = """
        {"id": "\(UUID().uuidString)", "firstName": "Ben", "lastName": "Hughes"}
        """.data(using: .utf8)!
        let player = try JSONDecoder().decode(Player.self, from: oldShapeJSON)
        #expect(player.preferredRole == nil)
    }

    @Test func resilientArrayDecodeSkipsOnlyTheMalformedEntry() throws {
        let json = """
        [
            {"id": "\(UUID().uuidString)", "firstName": "Good", "lastName": "One"},
            {"id": "not-a-uuid-so-this-entry-is-malformed"},
            {"id": "\(UUID().uuidString)", "firstName": "Also", "lastName": "Good"}
        ]
        """.data(using: .utf8)!

        let players = try JSONDecoder().decodeResilientArray(Player.self, from: json)
        #expect(players.count == 2)
        #expect(players.map(\.firstName) == ["Good", "Also"])
    }
}
