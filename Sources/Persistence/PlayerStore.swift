import Foundation

@MainActor
final class PlayerStore: ObservableObject {
    @Published private(set) var players: [Player] = []

    private let fileURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("players.json")
    }()

    init() {
        load()
        Task { await mergeFromCloud() }
    }

    func player(id: UUID?) -> Player? {
        guard let id else { return nil }
        return players.first(where: { $0.id == id })
    }

    func upsert(_ player: Player) {
        var player = player
        player.updatedAt = Date()
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
        } else {
            players.append(player)
        }
        save()
    }

    func delete(id: UUID) {
        players.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decodeResilientArray(Player.self, from: data) {
            players = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(players) else { return }
        try? data.write(to: fileURL, options: .atomic)
        Task { await CloudKitSyncService.pushPlayers(players) }
    }

    /// Best-effort iCloud sync: pulls whatever's in the private database and
    /// merges it in, newer `updatedAt` wins per player. A no-op if iCloud
    /// isn't set up yet (see `CloudKitSyncService`).
    private func mergeFromCloud() async {
        let remote = await CloudKitSyncService.pullPlayers()
        guard !remote.isEmpty else { return }

        var changed = false
        for remotePlayer in remote {
            if let index = players.firstIndex(where: { $0.id == remotePlayer.id }) {
                if remotePlayer.updatedAt > players[index].updatedAt {
                    players[index] = remotePlayer
                    changed = true
                }
            } else {
                players.append(remotePlayer)
                changed = true
            }
        }
        if changed { save() }
    }
}
