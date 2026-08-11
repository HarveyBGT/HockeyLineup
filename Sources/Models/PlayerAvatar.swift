import Foundation

/// A procedurally-drawn player avatar (no photo storage needed). Rendered by
/// `PlayerAvatarView` from a small set of interchangeable traits.
struct PlayerAvatar: Codable, Equatable {
    enum HairStyle: String, Codable, CaseIterable, Identifiable {
        case bald, short, long, curly, afro

        var id: String { rawValue }

        var label: String {
            switch self {
            case .bald: return "Bald"
            case .short: return "Short"
            case .long: return "Long"
            case .curly: return "Curly"
            case .afro: return "Afro"
            }
        }
    }

    enum BeardStyle: String, Codable, CaseIterable, Identifiable {
        case none, stubble, goatee, full

        var id: String { rawValue }

        var label: String {
            switch self {
            case .none: return "None"
            case .stubble: return "Stubble"
            case .goatee: return "Goatee"
            case .full: return "Full"
            }
        }
    }

    var skinToneHex: String = PlayerAvatar.skinTones[2]
    var hairStyle: HairStyle = .short
    var hairColorHex: String = PlayerAvatar.hairColors[0]
    var wearsGlasses: Bool = false
    var beardStyle: BeardStyle = .none

    static let skinTones = ["#F6D9C4", "#EAC1A0", "#D8A07C", "#B57C52", "#8D5A3B", "#5C3A22"]
    static let hairColors = ["#0B0B0B", "#4A2E1F", "#7A4B27", "#C99A3C", "#B23A2E", "#9AA0A6"]

    init(
        skinToneHex: String = PlayerAvatar.skinTones[2],
        hairStyle: HairStyle = .short,
        hairColorHex: String = PlayerAvatar.hairColors[0],
        wearsGlasses: Bool = false,
        beardStyle: BeardStyle = .none
    ) {
        self.skinToneHex = skinToneHex
        self.hairStyle = hairStyle
        self.hairColorHex = hairColorHex
        self.wearsGlasses = wearsGlasses
        self.beardStyle = beardStyle
    }

    // Manual Decodable so a trait added after a player was already saved (like
    // `beardStyle`) falls back to its default instead of failing the whole
    // decode and silently wiping the squad — this has bitten every schema
    // change made to this app so far.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        skinToneHex = try container.decodeIfPresent(String.self, forKey: .skinToneHex) ?? PlayerAvatar.skinTones[2]
        hairStyle = try container.decodeIfPresent(HairStyle.self, forKey: .hairStyle) ?? .short
        hairColorHex = try container.decodeIfPresent(String.self, forKey: .hairColorHex) ?? PlayerAvatar.hairColors[0]
        wearsGlasses = try container.decodeIfPresent(Bool.self, forKey: .wearsGlasses) ?? false
        beardStyle = try container.decodeIfPresent(BeardStyle.self, forKey: .beardStyle) ?? .none
    }
}
