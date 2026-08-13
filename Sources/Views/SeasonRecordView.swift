import SwiftUI
import Charts

/// Aggregate stats across every saved lineup: overall record, and each
/// squad member's appearances (pitch starts vs bench).
struct SeasonRecordView: View {
    @EnvironmentObject private var store: LineupStore
    @EnvironmentObject private var playerStore: PlayerStore
    @Environment(\.dismiss) private var dismiss

    private var playedCards: [LineupCard] { store.cards.filter { $0.result != nil } }
    private var record: SeasonRecord { store.cards.seasonRecord }

    /// Played matches oldest-first, for the form chart.
    private var formSequence: [LineupCard] {
        playedCards.sorted { ($0.matchDate ?? $0.createdAt) < ($1.matchDate ?? $1.createdAt) }
    }

    private var topAppearances: [PlayerStat] { Array(playerStats.prefix(8)) }

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
                        recordStat(value: record.wins, label: "Won", color: Theme.resultColor(.win))
                        recordStat(value: record.draws, label: "Drawn", color: Theme.resultColor(.draw))
                        recordStat(value: record.losses, label: "Lost", color: Theme.resultColor(.loss))
                    }
                    .padding(.vertical, 8)

                    if playedCards.isEmpty {
                        Text("No results recorded yet — add a score on any lineup to start building your record.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

                if formSequence.count > 1 {
                    Section("Form") {
                        formChart
                            .frame(height: 90)
                            .padding(.vertical, 4)
                    }
                }

                if !playerStats.isEmpty {
                    Section("Appearances") {
                        if topAppearances.count > 1 {
                            appearancesChart
                                .frame(height: CGFloat(topAppearances.count) * 28 + 20)
                                .padding(.vertical, 4)
                        }
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

    private var formChart: some View {
        Chart(Array(formSequence.enumerated()), id: \.element.id) { index, card in
            BarMark(
                x: .value("Match", index),
                y: .value("Result", 1)
            )
            .foregroundStyle(Theme.resultColor(card.result ?? .draw))
            .cornerRadius(4)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
    }

    private var appearancesChart: some View {
        Chart(topAppearances) { stat in
            BarMark(
                x: .value("Starts", stat.starts),
                y: .value("Player", stat.player.fullName.isEmpty ? "Unnamed Player" : stat.player.fullName)
            )
            .foregroundStyle(by: .value("Type", "Starts"))
            BarMark(
                x: .value("Bench", stat.benchAppearances),
                y: .value("Player", stat.player.fullName.isEmpty ? "Unnamed Player" : stat.player.fullName)
            )
            .foregroundStyle(by: .value("Type", "Bench"))
        }
        .chartForegroundStyleScale([
            "Starts": Theme.fortressBlue,
            "Bench": Theme.fortressGold,
        ])
        .chartLegend(position: .bottom, spacing: 8)
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
