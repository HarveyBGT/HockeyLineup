import Foundation

@MainActor
final class PlayerStore: ObservableObject {
    @Published private(set) var players: [Player] = []

    private let fileURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("players.json")
    }()

    private var saveTask: Task<Void, Never>?

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
        scheduleSave()
    }

    func delete(id: UUID) {
        players.removeAll { $0.id == id }
        scheduleSave()
    }

    /// Writes out immediately, skipping the debounce — call when the app is
    /// about to background so the most recent edit is never lost waiting
    /// out the quiet period.
    func flush() {
        saveTask?.cancel()
        persistNow()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decodeResilientArray(Player.self, from: data) {
            players = decoded
        }
    }

    /// Debounces rapid edits (typing, avatar tweaking) into a single disk
    /// write and CloudKit push instead of doing both on every keystroke —
    /// with a full squad roster, re-encoding and rewriting the whole file on
    /// every character typed is real, avoidable main-thread work.
    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            persistNow()
        }
    }

    private func persistNow() {
        let snapshot = players
        Task {
            await Self.write(snapshot, to: fileURL)
            await CloudKitSyncService.pushPlayers(snapshot)
        }
    }

    /// `nonisolated` so this runs off the main actor — encoding and writing
    /// a large squad roster should never be able to block scrolling or
    /// typing.
    private nonisolated static func write(_ players: [Player], to fileURL: URL) async {
        guard let data = try? JSONEncoder().encode(players) else { return }
        try? data.write(to: fileURL, options: .atomic)
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
        if changed { scheduleSave() }
    }
}
