import Foundation

@MainActor
final class LineupStore: ObservableObject {
    @Published private(set) var cards: [LineupCard] = []

    private let fileURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("lineups.json")
    }()

    init() {
        load()
    }

    func card(id: UUID) -> LineupCard? {
        cards.first(where: { $0.id == id })
    }

    func upsert(_ card: LineupCard) {
        var card = card
        card.updatedAt = Date()
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
        } else {
            cards.append(card)
        }
        save()
    }

    func delete(id: UUID) {
        cards.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([LineupCard].self, from: data) {
            cards = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(cards) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
