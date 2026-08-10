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
}
