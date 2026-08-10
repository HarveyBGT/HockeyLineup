import Foundation

/// A real London/South East hockey club's home pitch, used to style the
/// background of `PitchView`. Surface colour isn't published by any of these
/// clubs' own sites, so every entry defaults to blue — the standard modern
/// hockey-turf colour — except Barnes/Dukes Meadow, which is confirmed blue.
struct PitchVenue: Identifiable, Codable, Hashable {
    var id: String
    var clubName: String
    var groundName: String
    var location: String
    var colorHex: String

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
        PitchVenue(id: "barnes", clubName: "Barnes HC", groundName: "Dukes Meadow", location: "Chiswick, W4", colorHex: hockeyBlue),
        PitchVenue(id: "surbiton", clubName: "Surbiton HC", groundName: "Sugden Road", location: "Long Ditton", colorHex: hockeyBlue),
        PitchVenue(id: "hampstead-westminster", clubName: "Hampstead & Westminster HC", groundName: "Paddington Recreation Ground", location: "Maida Vale, W9", colorHex: hockeyBlue),
        PitchVenue(id: "southgate", clubName: "Southgate HC", groundName: "Southgate Hockey Centre, Trent Park", location: "Oakwood, N14", colorHex: hockeyBlue),
        PitchVenue(id: "richmond", clubName: "Richmond HC", groundName: "Home Ground", location: "Richmond, TW9", colorHex: hockeyBlue),
        PitchVenue(id: "wapping", clubName: "Wapping HC", groundName: "Lee Valley Hockey & Tennis Centre", location: "Olympic Park, Stratford", colorHex: hockeyBlue),
        PitchVenue(id: "spencer", clubName: "Spencer HC", groundName: "The Spencer Club", location: "Earlsfield, SW18", colorHex: hockeyBlue),
        PitchVenue(id: "old-loughtonians", clubName: "Old Loughtonians HC", groundName: "Roding Sports Centre", location: "Chigwell, Essex", colorHex: hockeyBlue),
        PitchVenue(id: "indian-gymkhana", clubName: "Indian Gymkhana HC", groundName: "Thornbury Avenue", location: "Osterley, TW7", colorHex: hockeyBlue),
        PitchVenue(id: "wimbledon", clubName: "Wimbledon HC", groundName: "Raynes Park High School", location: "Raynes Park, SW20", colorHex: hockeyBlue),
        PitchVenue(id: "teddington", clubName: "Teddington HC", groundName: "Teddington School", location: "Teddington, TW11", colorHex: hockeyBlue),
        PitchVenue(id: "bromley-beckenham", clubName: "Bromley & Beckenham HC", groundName: "Langley Park Girls' School", location: "Beckenham, BR3", colorHex: hockeyBlue),
        PitchVenue(id: "old-georgians", clubName: "Old Georgians HC", groundName: "Home Ground", location: "Addlestone, Surrey", colorHex: hockeyBlue),
        PitchVenue(id: "east-grinstead", clubName: "East Grinstead HC", groundName: "Home Ground", location: "East Grinstead, W. Sussex", colorHex: hockeyBlue),
        PitchVenue(id: "woking", clubName: "Woking HC", groundName: "Home Ground", location: "Woking, Surrey", colorHex: hockeyBlue),
        PitchVenue(id: "sevenoaks", clubName: "Sevenoaks HC", groundName: "Hollybush Lane", location: "Sevenoaks, Kent", colorHex: hockeyBlue),
        PitchVenue(id: "chelmsford", clubName: "Chelmsford HC", groundName: "Home Ground", location: "Chelmsford, Essex", colorHex: hockeyBlue),
        PitchVenue(id: "reading", clubName: "Reading HC", groundName: "Home Ground", location: "Reading, Berkshire", colorHex: hockeyBlue),
        PitchVenue(id: "romford", clubName: "Romford HC", groundName: "Home Ground", location: "Romford, Essex", colorHex: hockeyBlue),
        PitchVenue(id: "oxted", clubName: "Oxted HC", groundName: "Home Ground", location: "Oxted, Surrey", colorHex: hockeyBlue),
    ]

    static var `default`: PitchVenue { classicGreen }

    static func venue(id: String?) -> PitchVenue {
        guard let id else { return .default }
        return catalog.first(where: { $0.id == id }) ?? .default
    }
}
