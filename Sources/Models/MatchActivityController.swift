import ActivityKit
import Foundation

/// Owns the lifecycle of a match's Live Activity — starting, live score
/// adjustments, status changes, and ending — independent of the view that
/// displays it, so `LineupEditorView` doesn't have to carry ActivityKit
/// bookkeeping alongside everything else it does.
@MainActor
final class MatchActivityController: ObservableObject {
    @Published private(set) var currentActivity: Activity<MatchActivityAttributes>?
    @Published private(set) var ourScore = 0
    @Published private(set) var opponentScore = 0
    @Published private(set) var status = "Kickoff"
    /// Set when `start()` fails to actually start a Live Activity, so the
    /// view can tell the user why instead of the button silently doing
    /// nothing — the previous behaviour when this was only a `catch {}`.
    @Published var lastError: String?

    nonisolated static let statusOptions = ["Kickoff", "1st Half", "Half Time", "2nd Half", "Full Time"]

    var isLive: Bool { currentActivity != nil }

    /// Reattaches to an already-running activity for this opponent (e.g. the
    /// app was relaunched mid-match) rather than losing track of it.
    func reattach(opponentName: String) {
        guard let activity = Activity<MatchActivityAttributes>.activities.first(where: { $0.attributes.opponentName == opponentName }) else { return }
        currentActivity = activity
        ourScore = activity.content.state.ourScore
        opponentScore = activity.content.state.opponentScore
        status = activity.content.state.statusText
    }

    func start(opponentName: String, isHome: Bool, venueText: String, initialOurScore: Int, initialOpponentScore: Int) {
        guard currentActivity == nil else { return }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            lastError = "Live Activities are turned off for this app. Enable them in Settings → Fortress → Live Activities to use this."
            return
        }

        ourScore = Self.clamped(initialOurScore)
        opponentScore = Self.clamped(initialOpponentScore)
        status = "Kickoff"

        let attributes = MatchActivityAttributes(opponentName: opponentName, isHome: isHome, venueText: venueText)
        let state = MatchActivityAttributes.ContentState(ourScore: ourScore, opponentScore: opponentScore, statusText: status)
        do {
            currentActivity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
        } catch {
            lastError = "Couldn't start the Live Activity: \(error.localizedDescription)"
        }
    }

    func adjustOurScore(by delta: Int) {
        ourScore = Self.clamped(ourScore + delta)
        pushUpdate()
    }

    func adjustOpponentScore(by delta: Int) {
        opponentScore = Self.clamped(opponentScore + delta)
        pushUpdate()
    }

    func setStatus(_ newStatus: String) {
        status = newStatus
        pushUpdate()
    }

    /// Ends the activity and returns the final score for the caller to save
    /// onto the lineup card. Nil if nothing was running.
    @discardableResult
    func end() -> (ourScore: Int, opponentScore: Int)? {
        guard let currentActivity else { return nil }
        let finalState = MatchActivityAttributes.ContentState(ourScore: ourScore, opponentScore: opponentScore, statusText: "Full Time")
        Task { await currentActivity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .default) }
        self.currentActivity = nil
        return (ourScore, opponentScore)
    }

    private func pushUpdate() {
        guard let currentActivity else { return }
        let state = MatchActivityAttributes.ContentState(ourScore: ourScore, opponentScore: opponentScore, statusText: status)
        Task { await currentActivity.update(.init(state: state, staleDate: nil)) }
    }

    /// Scores never go negative — pulled out as a pure static func so it's
    /// testable without touching ActivityKit.
    nonisolated static func clamped(_ score: Int) -> Int { max(0, score) }
}
