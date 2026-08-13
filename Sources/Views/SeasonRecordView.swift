import SwiftUI

/// Aggregate stats across every saved lineup: overall record, and each
/// squad member's appearances (pitch starts vs bench).
struct SeasonRecordView: View {
    @EnvironmentObject private var store: LineupStore
    @EnvironmentObject private var playerStore: PlayerStore
    @Environment(\.dismiss) private var dismiss

    private var playedCards: [LineupCard] { store.cards.filter { $0.result != nil } }
    private var wins: Int { playedCards.filter { $0.result == .win }.count }
    private var draws: Int { playedCards.filter { $0.result == .draw }.count }
    private var losses: Int { playedCards.filter { $0.result == .loss }.count }

    private struct PlayerStat: Identifiable {
        var id: UUID
        var player: Player
        var starts: Int
        var benchAppearances: Int
        var total: Int { starts + benchAppearances }
    }

    private var playerStats: [PlayerStat] {
        var starts: [UUID: Int] = [:]
        var benchApps: [UUID: Int] = [:]
        for card in store.cards {
            for id in card.playerIDs.compactMap({ $0 }) { starts[id, default: 0] += 1 }
            for id in card.benchPlayerIDs.compactMap({ $0 }) { benchApps[id, default: 0] += 1 }
        }
        let allIDs = Set(starts.keys).union(benchApps.keys)
        return allIDs.compactMap { id in
            guard let player = playerStore.player(id: id) else { return nil }
            return PlayerStat(id: id, player: player, starts: starts[id] ?? 0, benchAppearances: benchApps[id] ?? 0)
        }
        .sorted { $0.total == $1.total ? $0.player.fullName < $1.player.fullName : $0.total > $1.total }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 0) {
                        recordStat(value: wins, label: "Won", color: Theme.resultColor(.win))
                        recordStat(value: draws, label: "Drawn", color: Theme.resultColor(.draw))
                        recordStat(value: losses, label: "Lost", color: Theme.resultColor(.loss))
                    }
                    .padding(.vertical, 8)

                    if playedCards.isEmpty {
                        Text("No results recorded yet — add a score on any lineup to start building your record.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

                if !playerStats.isEmpty {
                    Section("Appearances") {
                        ForEach(playerStats) { stat in
                            HStack(spacing: 12) {
                                PlayerAvatarView(avatar: stat.player.avatar, size: 32)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stat.player.fullName.isEmpty ? "Unnamed Player" : stat.player.fullName)
                                        .font(.system(size: 15, weight: .medium))
                                    Text("\(stat.starts) start\(stat.starts == 1 ? "" : "s") · \(stat.benchAppearances) bench")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(stat.total)")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("Season Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func recordStat(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SeasonRecordView()
        .environmentObject(LineupStore())
        .environmentObject(PlayerStore())
}
