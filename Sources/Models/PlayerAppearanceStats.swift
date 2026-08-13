import Foundation

/// A squad member's appearance count across a set of lineups — pitch starts
/// vs bench — pulled out of `SeasonRecordView` so the aggregation is
/// testable without a view or a live `PlayerStore`.
struct PlayerAppearanceStats: Identifiable, Equatable {
    var id: UUID
    var player: Player
    var starts: Int
    var benchAppearances: Int
    var total: Int { starts + benchAppearances }
}

extension Array where Element == LineupCard {
    /// Appearance counts for every player who's featured in at least one of
    /// these lineups, sorted by total descending then name. `playerLookup`
    /// resolves an ID to a `Player` — pass `playerStore.player(id:)` in the
    /// app, or a plain dictionary lookup in tests.
    func playerAppearanceStats(playerLookup: (UUID) -> Player?) -> [PlayerAppearanceStats] {
        var starts: [UUID: Int] = [:]
        var benchApps: [UUID: Int] = [:]
        for card in self {
            for id in card.playerIDs.compactMap({ $0 }) { starts[id, default: 0] += 1 }
            for id in card.benchPlayerIDs.compactMap({ $0 }) { benchApps[id, default: 0] += 1 }
        }
        let allIDs = Set(starts.keys).union(benchApps.keys)
        return allIDs.compactMap { id in
            guard let player = playerLookup(id) else { return nil }
            return PlayerAppearanceStats(id: id, player: player, starts: starts[id] ?? 0, benchAppearances: benchApps[id] ?? 0)
        }
        .sorted { $0.total == $1.total ? $0.player.fullName < $1.player.fullName : $0.total > $1.total }
    }
}
