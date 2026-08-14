import Foundation

@MainActor
final class LineupStore: ObservableObject {
    @Published private(set) var cards: [LineupCard] = []

    private let fileURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("lineups.json")
    }()

    private var saveTask: Task<Void, Never>?

    init() {
        load()
        Task { await mergeFromCloud() }
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
        scheduleSave()
        MatchReminderScheduler.reschedule(for: card)
    }

    func delete(id: UUID) {
        cards.removeAll { $0.id == id }
        scheduleSave()
        MatchReminderScheduler.cancelReminder(for: id)
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
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decodeResilientArray(LineupCard.self, from: data) {
            cards = decoded
        }
    }

    /// Debounces rapid edits (typing, dragging) into a single disk write and
    /// CloudKit push instead of doing both on every keystroke — with a full
    /// season of saved lineups, re-encoding and rewriting the whole file on
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
        let snapshot = cards
        Task {
            await Self.write(snapshot, to: fileURL)
            await CloudKitSyncService.pushLineups(snapshot)
        }
    }

    /// `nonisolated` so this runs off the main actor — encoding and writing
    /// a large lineup history should never be able to block scrolling or
    /// typing.
    private nonisolated static func write(_ cards: [LineupCard], to fileURL: URL) async {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(cards) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    /// Best-effort iCloud sync: pulls whatever's in the private database and
    /// merges it in, newer `updatedAt` wins per lineup. A no-op if iCloud
    /// isn't set up yet (see `CloudKitSyncService`).
    private func mergeFromCloud() async {
        let remote = await CloudKitSyncService.pullLineups()
        guard !remote.isEmpty else { return }

        var changed = false
        for remoteCard in remote {
            if let index = cards.firstIndex(where: { $0.id == remoteCard.id }) {
                if remoteCard.updatedAt > cards[index].updatedAt {
                    cards[index] = remoteCard
                    changed = true
                }
            } else {
                cards.append(remoteCard)
                changed = true
            }
        }
        if changed { scheduleSave() }
    }
}
