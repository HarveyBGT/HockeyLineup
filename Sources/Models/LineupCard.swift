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
