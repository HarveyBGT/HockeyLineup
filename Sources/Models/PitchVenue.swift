import Foundation

/// A hand-illustrated motif layered over a club's crest shield, beyond the
/// default initials. Not claiming to be any club's real badge — just a
/// stylised flourish for the ones with an obvious visual hook.
enum ClubMotif: String, Codable, Hashable {
    case monogram
    case bridge
    case tree
}

/// The visual identity for a club's crest — decoupled from `PitchVenue` so
/// any team name (including opponents we haven't curated a pitch for) can
/// still get a consistent flat crest. See `ClubCrestView`.
struct ClubCrest: Hashable {
    var initials: String
    var colorHex: String
    var motif: ClubMotif

    private static let fallbackPalette = [
        "#3E5C76", "#7A4B27", "#5B2A86", "#1D5C3A",
        "#8C1F28", "#146B5C", "#7A1F2B", "#1A4E8A",
    ]

    /// Best-effort crest for an arbitrary team/opposition name that might not
    /// be one of our curated London clubs — matches a known club if the name
    /// contains it, otherwise deterministically synthesizes a colour +
    /// monogram so every opponent still gets a consistent-looking crest.
    static func forTeamName(_ name: String) -> ClubCrest {
        let lowered = name.lowercased()
        if let match = PitchVenue.catalog.first(where: {
            $0.id != PitchVenue.classicGreen.id &&
            lowered.contains($0.clubName.replacingOccurrences(of: " HC", with: "").lowercased())
        }) {
            return match.crest
        }

        let words = name.split(separator: " ").filter { $0.count > 1 }
        let letters = words.prefix(2).compactMap { $0.first }
        let initials = String(letters).uppercased()
        let color = fallbackPalette[abs(name.hashValue) % fallbackPalette.count]
        return ClubCrest(initials: initials.isEmpty ? "?" : initials, colorHex: color, motif: .monogram)
    }
}

/// A real London/South East hockey club's home pitch, used to style the
/// background of `PitchView`. Surface colour isn't published by any of these
/// clubs' own sites, so every entry defaults to blue — the standard modern
/// hockey-turf colour — except Barnes/Dukes Meadow, which is confirmed blue.
/// `crestColorHex` and `crestMotif` are likewise stylised, not real club
/// branding — see `ClubCrestView`.
struct PitchVenue: Identifiable, Codable, Hashable {
    var id: String
    var clubName: String
    var groundName: String
    var location: String
    var colorHex: String
    var crestColorHex: String = "#2B3A55"
    var crestMotif: ClubMotif = .monogram

    static let classicGreen = PitchVenue(
        id: "classic-green",
        clubName: "Classic Green",
        groundName: "Default Pitch",
        location: "No club association",
        colorHex: "#1E7A46"
    )

    private static let hockeyBlue = "#1C63A8"

    static let catalog: [PitchVenue] = [
        classicGreen,
        PitchVenue(id: "barnes", clubName: "Barnes HC", groundName: "Dukes Meadow", location: "Chiswick, W4", colorHex: hockeyBlue, crestColorHex: "#0B2545", crestMotif: .bridge),
        PitchVenue(id: "surbiton", clubName: "Surbiton HC", groundName: "Sugden Road", location: "Long Ditton", colorHex: hockeyBlue, crestColorHex: "#7A1F2B"),
        PitchVenue(id: "hampstead-westminster", clubName: "Hampstead & Westminster HC", groundName: "Paddington Recreation Ground", location: "Maida Vale, W9", colorHex: hockeyBlue, crestColorHex: "#4B2E83"),
        PitchVenue(id: "southgate", clubName: "Southgate HC", groundName: "Southgate Hockey Centre, Trent Park", location: "Oakwood, N14", colorHex: hockeyBlue, crestColorHex: "#1D5C3A"),
        PitchVenue(id: "richmond", clubName: "Richmond HC", groundName: "Home Ground", location: "Richmond, TW9", colorHex: hockeyBlue, crestColorHex: "#12472E"),
        PitchVenue(id: "wapping", clubName: "Wapping HC", groundName: "Lee Valley Hockey & Tennis Centre", location: "Olympic Park, Stratford", colorHex: hockeyBlue, crestColorHex: "#0E6E6E"),
        PitchVenue(id: "spencer", clubName: "Spencer HC", groundName: "The Spencer Club", location: "Earlsfield, SW18", colorHex: hockeyBlue, crestColorHex: "#6E1423"),
        PitchVenue(id: "old-loughtonians", clubName: "Old Loughtonians HC", groundName: "Roding Sports Centre", location: "Chigwell, Essex", colorHex: hockeyBlue, crestColorHex: "#1B3358"),
        PitchVenue(id: "indian-gymkhana", clubName: "Indian Gymkhana HC", groundName: "Thornbury Avenue", location: "Osterley, TW7", colorHex: hockeyBlue, crestColorHex: "#C1552C"),
        PitchVenue(id: "wimbledon", clubName: "Wimbledon HC", groundName: "Raynes Park High School", location: "Raynes Park, SW20", colorHex: hockeyBlue, crestColorHex: "#5B2A86"),
        PitchVenue(id: "teddington", clubName: "Teddington HC", groundName: "Teddington School", location: "Teddington, TW11", colorHex: hockeyBlue, crestColorHex: "#C94F7C", crestMotif: .tree),
        PitchVenue(id: "bromley-beckenham", clubName: "Bromley & Beckenham HC", groundName: "Langley Park Girls' School", location: "Beckenham, BR3", colorHex: hockeyBlue, crestColorHex: "#8C1F28"),
        PitchVenue(id: "old-georgians", clubName: "Old Georgians HC", groundName: "Home Ground", location: "Addlestone, Surrey", colorHex: hockeyBlue, crestColorHex: "#22314F"),
        PitchVenue(id: "east-grinstead", clubName: "East Grinstead HC", groundName: "Home Ground", location: "East Grinstead, W. Sussex", colorHex: hockeyBlue, crestColorHex: "#1A4E8A"),
        PitchVenue(id: "woking", clubName: "Woking HC", groundName: "Home Ground", location: "Woking, Surrey", colorHex: hockeyBlue, crestColorHex: "#7A2331"),
        PitchVenue(id: "sevenoaks", clubName: "Sevenoaks HC", groundName: "Hollybush Lane", location: "Sevenoaks, Kent", colorHex: hockeyBlue, crestColorHex: "#20603D"),
        PitchVenue(id: "chelmsford", clubName: "Chelmsford HC", groundName: "Home Ground", location: "Chelmsford, Essex", colorHex: hockeyBlue, crestColorHex: "#2B6CB0"),
        PitchVenue(id: "reading", clubName: "Reading HC", groundName: "Home Ground", location: "Reading, Berkshire", colorHex: hockeyBlue, crestColorHex: "#1E429F"),
        PitchVenue(id: "romford", clubName: "Romford HC", groundName: "Home Ground", location: "Romford, Essex", colorHex: hockeyBlue, crestColorHex: "#1F2A44"),
        PitchVenue(id: "oxted", clubName: "Oxted HC", groundName: "Home Ground", location: "Oxted, Surrey", colorHex: hockeyBlue, crestColorHex: "#146B5C"),
    ]

    static var `default`: PitchVenue { classicGreen }

    static func venue(id: String?) -> PitchVenue {
        guard let id else { return .default }
        return catalog.first(where: { $0.id == id }) ?? .default
    }

    /// Short crest initials derived from the club name (e.g. "Barnes HC" → "BA").
    var initials: String {
        let words = clubName
            .replacingOccurrences(of: "&", with: " ")
            .split(separator: " ")
            .filter { $0.count > 1 || $0.first?.isUppercase == true }
        let letters = words.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    var crest: ClubCrest {
        ClubCrest(initials: initials, colorHex: crestColorHex, motif: crestMotif)
    }
}
