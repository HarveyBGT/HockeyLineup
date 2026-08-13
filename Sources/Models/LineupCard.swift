import Foundation

/// A single spot a player can occupy in a lineup: a pitch position (by
/// formation index) or a bench slot (by index). Used to guarantee a player
/// never occupies two spots at once.
enum PlayerSlot: Equatable {
    case pitch(Int)
    case bench(Int)

    /// A compact string encoding for drag-and-drop payloads (e.g. "pitch:3").
    var dragPayload: String {
        switch self {
        case .pitch(let index): return "pitch:\(index)"
        case .bench(let index): return "bench:\(index)"
        }
    }

    init?(dragPayload: String) {
        let parts = dragPayload.split(separator: ":")
        guard parts.count == 2, let index = Int(parts[1]) else { return nil }
        switch parts[0] {
        case "pitch": self = .pitch(index)
        case "bench": self = .bench(index)
        default: return nil
        }
    }
}

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
    var homeScore: Int? = nil
    var awayScore: Int? = nil
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

    /// Match date only, e.g. "Sat 19 Sep". Empty if not set.
    var matchDateText: String {
        guard let matchDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: matchDate)
    }

    /// Kick-off time only, e.g. "14:00". Empty if not set.
    var kickoffTimeText: String {
        guard let matchDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: matchDate)
    }

    /// Where the match is being played — ground name and location for home
    /// fixtures (we know Barnes' own grounds), or the opposition's real
    /// ground for away fixtures if they're a curated club; falls back to
    /// just naming the opposition when we don't have their venue. Empty if
    /// there's nothing to say.
    var venueText: String {
        if isHome {
            let venue = pitchVenue
            guard venue.id != PitchVenue.classicGreen.id else { return "" }
            return "\(venue.groundName), \(venue.location)"
        } else if let venue = PitchVenue.matchingCuratedVenue(forTeamName: opposition) {
            return "\(venue.groundName), \(venue.location)"
        } else {
            return opposition.isEmpty ? "" : "\(opposition)'s ground"
        }
    }

    /// "3 - 1" in home-away order. Nil until both scores are recorded.
    var scoreText: String? {
        guard let homeScore, let awayScore else { return nil }
        return "\(homeScore) - \(awayScore)"
    }

    /// Result from *our* side regardless of home/away. Nil until both
    /// scores are recorded.
    var result: MatchResult? {
        guard let homeScore, let awayScore else { return nil }
        let ourScore = isHome ? homeScore : awayScore
        let theirScore = isHome ? awayScore : homeScore
        if ourScore > theirScore { return .win }
        if ourScore < theirScore { return .loss }
        return .draw
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
        homeScore = try container.decodeIfPresent(Int.self, forKey: .homeScore)
        awayScore = try container.decodeIfPresent(Int.self, forKey: .awayScore)
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

    /// Every player currently placed somewhere in this lineup — pitch or bench.
    var allAssignedPlayerIDs: Set<UUID> {
        Set((playerIDs + benchPlayerIDs).compactMap { $0 })
    }

    /// Where a player is currently placed, if anywhere.
    func slot(of playerID: UUID) -> PlayerSlot? {
        if let index = playerIDs.firstIndex(of: playerID) { return .pitch(index) }
        if let index = benchPlayerIDs.firstIndex(of: playerID) { return .bench(index) }
        return nil
    }

    /// Assigns `playerID` to `slot`, first vacating wherever else that player
    /// is currently placed. This is the only way slots should be mutated —
    /// it guarantees a player can never occupy two spots (two pitch
    /// positions, or a pitch position and the bench) at once. Assigning
    /// `nil` just clears `slot`.
    mutating func assign(_ playerID: UUID?, to slot: PlayerSlot) {
        if let playerID, let currentSlot = self.slot(of: playerID), currentSlot != slot {
            place(nil, at: currentSlot)
        }
        place(playerID, at: slot)
    }

    /// The player currently occupying `slot`, if any.
    func player(at slot: PlayerSlot) -> UUID? {
        switch slot {
        case .pitch(let index):
            return playerIDs.indices.contains(index) ? playerIDs[index] : nil
        case .bench(let index):
            return benchPlayerIDs.indices.contains(index) ? benchPlayerIDs[index] : nil
        }
    }

    /// Exchanges whatever is in `source` and `destination` — used for
    /// drag-and-drop. If one side is empty this reads as a plain move; if
    /// both are occupied the two players trade places. Either way no
    /// duplication is possible, since it's just swapping the contents of
    /// exactly two slots.
    mutating func swapOrMove(from source: PlayerSlot, to destination: PlayerSlot) {
        guard source != destination else { return }
        let sourcePlayer = player(at: source)
        let destinationPlayer = player(at: destination)
        place(destinationPlayer, at: source)
        place(sourcePlayer, at: destination)
    }

    /// Records a final score from *our* perspective, mapping it onto the
    /// home/away score fields correctly regardless of which side we're on.
    mutating func recordResult(ourScore: Int, opponentScore: Int) {
        if isHome {
            homeScore = ourScore
            awayScore = opponentScore
        } else {
            homeScore = opponentScore
            awayScore = ourScore
        }
    }

    /// Short label for where `playerID` is currently placed, unless that's
    /// `slot` itself (nothing to report — that's the position being edited).
    func placementLabel(for playerID: UUID, excluding slot: PlayerSlot) -> String? {
        guard let currentSlot = self.slot(of: playerID), currentSlot != slot else { return nil }
        switch currentSlot {
        case .pitch(let index):
            let role = formation.positions.first(where: { $0.id == index })?.role
            return role.map { "On pitch — \($0.rawValue)" } ?? "On pitch"
        case .bench:
            return "On bench"
        }
    }

    private mutating func place(_ playerID: UUID?, at slot: PlayerSlot) {
        switch slot {
        case .pitch(let index):
            guard playerIDs.indices.contains(index) else { return }
            playerIDs[index] = playerID
        case .bench(let index):
            guard benchPlayerIDs.indices.contains(index) else { return }
            benchPlayerIDs[index] = playerID
        }
    }
}
