import CloudKit
import Foundation

/// Best-effort iCloud sync for lineups and the squad, layered on top of the
/// local JSON stores rather than replacing them — local files stay the
/// source of truth for instant reads and offline use; this just keeps them
/// in step with the same iCloud account's other devices.
///
/// Requires the iCloud capability (CloudKit service, container
/// "iCloud.com.example.hockeylineup") to be provisioned for this app's App
/// ID — a one-time step in Xcode's Signing & Capabilities, done while
/// signed into an Apple ID, which can't be done from outside Xcode. Until
/// that's done (or if the user isn't signed into iCloud, or is offline),
/// every call here just fails silently and the app behaves exactly as it
/// did before sync existed.
enum CloudKitSyncService {
    private static let container = CKContainer(identifier: "iCloud.com.example.hockeylineup")
    private static var database: CKDatabase { container.privateCloudDatabase }

    private enum RecordType {
        static let lineupCard = "LineupCard"
        static let player = "Player"
    }

    static func pushLineups(_ cards: [LineupCard]) async {
        await push(items: cards, updatedAt: { $0.updatedAt }, recordType: RecordType.lineupCard)
    }

    static func pullLineups() async -> [LineupCard] {
        await pull(recordType: RecordType.lineupCard)
    }

    static func pushPlayers(_ players: [Player]) async {
        await push(items: players, updatedAt: { $0.updatedAt }, recordType: RecordType.player)
    }

    static func pullPlayers() async -> [Player] {
        await pull(recordType: RecordType.player)
    }

    // MARK: - Generic push/pull, keyed by each item's `id`

    private static func push<T: Identifiable & Encodable>(
        items: [T],
        updatedAt: (T) -> Date,
        recordType: String
    ) async where T.ID == UUID {
        guard !items.isEmpty else { return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let records: [CKRecord] = items.compactMap { item in
            guard let payload = try? encoder.encode(item) else { return nil }
            let record = CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: item.id.uuidString))
            record["payload"] = payload as NSData
            record["updatedAt"] = updatedAt(item) as NSDate
            return record
        }
        guard !records.isEmpty else { return }

        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            operation.modifyRecordsResultBlock = { _ in continuation.resume() }
            database.add(operation)
        }
    }

    private static func pull<T: Decodable>(recordType: String) async -> [T] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        do {
            let (matchResults, _) = try await database.records(matching: query)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return matchResults.compactMap { _, result in
                guard case .success(let record) = result, let payload = record["payload"] as? Data else { return nil }
                return try? decoder.decode(T.self, from: payload)
            }
        } catch {
            // No iCloud account, container not provisioned yet, offline,
            // record type doesn't exist on the server yet, etc. Sync is
            // best-effort — treat all of these as "nothing remote yet".
            return []
        }
    }
}
