import SwiftUI

/// Standalone squad management screen: view, edit, and delete every player
/// stored in the app, independent of any single lineup.
struct PlayerDatabaseView: View {
    @EnvironmentObject private var playerStore: PlayerStore
    @Environment(\.dismiss) private var dismiss

    @State private var showNewPlayerForm = false
    @State private var editingPlayer: Player?

    private var sortedPlayers: [Player] {
        playerStore.players.sorted { $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !playerStore.players.isEmpty {
                    summaryHeader
                }

                Group {
                    if playerStore.players.isEmpty {
                        emptyState
                    } else {
                        List {
                            ForEach(sortedPlayers) { player in
                                Button {
                                    editingPlayer = player
                                } label: {
                                    PlayerDatabaseRow(player: player)
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete(perform: delete)
                        }
                    }
                }
            }
            .navigationTitle("Squad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewPlayerForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showNewPlayerForm) {
                PlayerFormView { newPlayer in
                    playerStore.upsert(newPlayer)
                }
            }
            .sheet(item: $editingPlayer) { player in
                PlayerFormView(existingPlayer: player, onSave: { updated in
                    playerStore.upsert(updated)
                }, onDelete: {
                    playerStore.delete(id: player.id)
                })
            }
        }
    }

    private var summaryHeader: some View {
        let summary = playerStore.players.squadSummary
        return HStack(spacing: 0) {
            summaryStat(value: summary.total, label: "Players")
            summaryStat(value: summary.goalkeepers, label: "Keepers")
            summaryStat(value: summary.withPreferredRole, label: "Positions Set")
        }
        .padding(.vertical, 14)
        .groupedCard()
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private func summaryStat(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.fortressBlue)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.fortressBlue)
            Text("No Players Yet")
                .font(.system(size: 19, weight: .bold, design: .rounded))
            Text("Add players to your squad database to reuse them across lineups.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Add Player") { showNewPlayerForm = true }
                .modifier(ProminentGlassButtonModifier())
                .tint(Theme.fortressBlue)
        }
        .padding(.horizontal, 32)
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            playerStore.delete(id: sortedPlayers[index].id)
        }
    }
}

private struct PlayerDatabaseRow: View {
    var player: Player

    var body: some View {
        HStack(spacing: 14) {
            PlayerAvatarView(avatar: player.avatar, size: 40)

            VStack(alignment: .leading, spacing: 5) {
                Text(player.fullName.isEmpty ? "Unnamed Player" : player.fullName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    if let number = player.squadNumber {
                        Text("#\(number)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    if player.isGoalkeeper {
                        statusBadge("GK", color: Theme.fortressBlue)
                    }
                    if let badge = player.captaincyBadge {
                        statusBadge(badge, color: Theme.fortressGold)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private func statusBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color, in: Capsule())
    }
}

#Preview {
    PlayerDatabaseView()
        .environmentObject(PlayerStore())
}
