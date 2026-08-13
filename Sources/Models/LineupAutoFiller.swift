import Foundation

/// Fills empty lineup slots from the squad database — pulled out of
/// `LineupEditorView` so this logic is testable without instantiating a view.
enum LineupAutoFiller {
    /// Squad members not currently placed anywhere in `card`, in a sensible
    /// pick order: numbered players first (by number), then unnumbered
    /// players alphabetically.
    static func unassignedSquad(_ squad: [Player], notIn card: LineupCard) -> [Player] {
        squad
            .filter { card.slot(of: $0.id) == nil }
            .sorted {
                switch ($0.squadNumber, $1.squadNumber) {
                case let (a?, b?): return a < b
                case (nil, nil): return $0.fullName < $1.fullName
                case (nil, _): return false
                case (_, nil): return true
                }
            }
    }

    /// Fills every empty pitch position, then every empty bench slot, from
    /// `squad` — a quick starting point rather than tapping each spot
    /// individually. Skips anyone already placed; stops gracefully if the
    /// squad runs out before every spot is filled.
    static func fill(_ card: inout LineupCard, from squad: [Player]) {
        var pool = unassignedSquad(squad, notIn: card)

        for index in card.playerIDs.indices where card.playerIDs[index] == nil {
            guard !pool.isEmpty else { break }
            let role = card.formation.positions.first(where: { $0.id == index })?.role
            let pickIndex = bestCandidateIndex(in: pool, for: role)
            let player = pool.remove(at: pickIndex)
            card.assign(player.id, to: .pitch(index))
        }

        for index in card.benchPlayerIDs.indices where card.benchPlayerIDs[index] == nil {
            guard !pool.isEmpty else { break }
            let player = pool.removeFirst()
            card.assign(player.id, to: .bench(index))
        }
    }

    /// The best-matching pool index for `role`: someone whose preferred
    /// position matches, falling back to the goalkeeper flag for GK, falling
    /// back to someone with no stated preference at all rather than bumping
    /// a player into a role they've explicitly said isn't theirs (a striker
    /// into goal, say), falling back to whoever's next in the pick order if
    /// everyone left has some other explicit preference.
    static func bestCandidateIndex(in pool: [Player], for role: PositionRole?) -> Int {
        guard let role else { return 0 }
        if let index = pool.firstIndex(where: { $0.preferredRole == role }) {
            return index
        }
        if role == .goalkeeper, let index = pool.firstIndex(where: { $0.isGoalkeeper }) {
            return index
        }
        if let index = pool.firstIndex(where: { $0.preferredRole == nil }) {
            return index
        }
        return 0
    }
}
