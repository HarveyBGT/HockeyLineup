import Foundation

struct LineupCard: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var clubName: String = ""
    var matchSubtitle: String = ""
    var formationID: String = Formation.presets[0].id
    var playerIDs: [UUID?] = Array(repeating: nil, count: Formation.presets[0].positions.count)
    var colorHex: String = "#1E6B45"
    var pitchVenueID: String? = nil
    var logoImageData: Data?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var formation: Formation {
        Formation.preset(id: formationID)
    }

    var pitchVenue: PitchVenue {
        PitchVenue.venue(id: pitchVenueID)
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
