import Foundation

/// Split out from `LineupCard.swift` so lightweight consumers (like
/// `Theme.resultColor` used from the widget extension) don't have to pull in
/// the whole lineup model graph.
enum MatchResult: String, Codable {
    case win, draw, loss

    var label: String {
        switch self {
        case .win: return "Win"
        case .draw: return "Draw"
        case .loss: return "Loss"
        }
    }
}
