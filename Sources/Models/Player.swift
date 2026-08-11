import Foundation

struct Player: Identifiable, Codable, Equatable {
    enum Captaincy: String, Codable {
        case none, captain, viceCaptain
    }

    var id: UUID = UUID()
    var firstName: String = ""
    var lastName: String = ""
    var squadNumber: Int?
    var isGoalkeeper: Bool = false
    var captaincy: Captaincy = .none
    var avatar: PlayerAvatar = PlayerAvatar()

    var fullName: String {
        [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
    }

    var captaincyBadge: String? {
        switch captaincy {
        case .none: return nil
        case .captain: return "C"
        case .viceCaptain: return "VC"
        }
    }

    init(
        id: UUID = UUID(),
        firstName: String = "",
        lastName: String = "",
        squadNumber: Int? = nil,
        isGoalkeeper: Bool = false,
        captaincy: Captaincy = .none,
        avatar: PlayerAvatar = PlayerAvatar()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.squadNumber = squadNumber
        self.isGoalkeeper = isGoalkeeper
        self.captaincy = captaincy
        self.avatar = avatar
    }

    // Manual Decodable, matching `PlayerAvatar`: any field added after this
    // player was saved falls back to a sane default instead of the whole
    // squad silently resetting to empty.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        squadNumber = try container.decodeIfPresent(Int.self, forKey: .squadNumber)
        isGoalkeeper = try container.decodeIfPresent(Bool.self, forKey: .isGoalkeeper) ?? false
        captaincy = try container.decodeIfPresent(Captaincy.self, forKey: .captaincy) ?? .none
        avatar = try container.decodeIfPresent(PlayerAvatar.self, forKey: .avatar) ?? PlayerAvatar()
    }
}
