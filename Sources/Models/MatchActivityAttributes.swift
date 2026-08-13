import ActivityKit
import Foundation

/// Shared between the app (starts/updates/ends the activity) and the widget
/// extension (renders it on the Lock Screen and in the Dynamic Island).
/// Scores are tracked as "ours" vs "opponent's" rather than home/away, since
/// that's what's actually useful to glance at mid-match regardless of venue.
struct MatchActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var ourScore: Int
        var opponentScore: Int
        var statusText: String
    }

    var opponentName: String
    var isHome: Bool
    var venueText: String
}
