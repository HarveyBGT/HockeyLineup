import Foundation

struct LineupCard: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var clubName: String = MyTeam.name
    var opposition: String = ""
    var matchDate: Date? = nil
    var isHome: Bool = true
    var linkedFixtureID: String? = nil
    var formationID: String = Formation.presets[0].id
    var playerIDs: [UUID?] = Array(repeating: nil, count: Formation.presets[0].positions.count)
    var homeColorHex: String = "#1C63A8"
    var awayColorHex: String = "#FFFFFF"
    var pitchVenueID: String? = MyTeam.pitchVenueID
    var benchPlayerIDs: [UUID?] = Array(repeating: nil, count: 5)
    var coachName: String = ""
    var umpireOneName: String = ""
    var umpireTwoName: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var formation: Formation {
        Formation.preset(id: formationID)
    }

    var pitchVenue: PitchVenue {
        PitchVenue.venue(id: pitchVenueID)
    }

    /// The kit colour that should currently be shown, given home/away.
    var activeColorHex: String {
        isHome ? homeColorHex : awayColorHex
    }

    /// My team's crest — always Barnes, regardless of home/away, since this
    /// is always representing our own lineup card.
    var myCrest: ClubCrest {
        PitchVenue.venue(id: MyTeam.pitchVenueID).crest
    }

    /// A human-readable summary of the match details, e.g. "vs Old
    /// Tonbridgians M1 — Sat 19 Sep, Home". Empty if nothing's set yet.
    var matchSummaryText: String {
        let oppositionText = opposition.isEmpty ? "" : "vs \(opposition)"

        var trailing: [String] = []
        if let matchDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE d MMM"
            trailing.append(formatter.string(from: matchDate))
        }
        trailing.append(isHome ? "Home" : "Away")
        let trailingText = trailing.joined(separator: ", ")

        guard !oppositionText.isEmpty || matchDate != nil else { return "" }
        return oppositionText.isEmpty ? trailingText : "\(oppositionText) — \(trailingText)"
    }

    init(formation: Formation) {
        self.formationID = formation.id
        self.playerIDs = Array(repeating: nil, count: formation.positions.count)
    }

    // Manual Decodable: every field this card has gained across redesigns
    // (kit colours, bench, coach, umpires...) falls back to its default
    // rather than failing the decode and resetting every saved lineup —
    // this struct has changed shape more than any other model in the app.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        clubName = try container.decodeIfPresent(String.self, forKey: .clubName) ?? MyTeam.name
        opposition = try container.decodeIfPresent(String.self, forKey: .opposition) ?? ""
        matchDate = try container.decodeIfPresent(Date.self, forKey: .matchDate)
        isHome = try container.decodeIfPresent(Bool.self, forKey: .isHome) ?? true
        linkedFixtureID = try container.decodeIfPresent(String.self, forKey: .linkedFixtureID)
        formationID = try container.decodeIfPresent(String.self, forKey: .formationID) ?? Formation.presets[0].id
        playerIDs = try container.decodeIfPresent([UUID?].self, forKey: .playerIDs)
            ?? Array(repeating: nil, count: Formation.preset(id: formationID).positions.count)
        homeColorHex = try container.decodeIfPresent(String.self, forKey: .homeColorHex) ?? "#1C63A8"
        awayColorHex = try container.decodeIfPresent(String.self, forKey: .awayColorHex) ?? "#FFFFFF"
        pitchVenueID = try container.decodeIfPresent(String.self, forKey: .pitchVenueID) ?? MyTeam.pitchVenueID
        benchPlayerIDs = try container.decodeIfPresent([UUID?].self, forKey: .benchPlayerIDs) ?? Array(repeating: nil, count: 5)
        coachName = try container.decodeIfPresent(String.self, forKey: .coachName) ?? ""
        umpireOneName = try container.decodeIfPresent(String.self, forKey: .umpireOneName) ?? ""
        umpireTwoName = try container.decodeIfPresent(String.self, forKey: .umpireTwoName) ?? ""
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }

    /// Keeps playerIDs aligned with the current formation's position count.
    mutating func conformPlayerIDsToFormation() {
        let count = formation.positions.count
        if playerIDs.count < count {
            playerIDs.append(contentsOf: Array(repeating: nil, count: count - playerIDs.count))
        } else if playerIDs.count > count {
            playerIDs = Array(playerIDs.prefix(count))
        }
    }
}
