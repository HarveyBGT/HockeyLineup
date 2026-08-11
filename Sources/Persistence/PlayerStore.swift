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
    }

    func player(id: UUID?) -> Player? {
        guard let id else { return nil }
        return players.first(where: { $0.id == id })
    }

    func upsert(_ player: Player) {
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
    }
}
