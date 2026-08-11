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
            Group {
                if playerStore.players.isEmpty {
                    ContentUnavailableView {
                        Label("No Players Yet", systemImage: "person.3.fill")
                    } description: {
                        Text("Add players to your squad database to reuse them across lineups.")
                    } actions: {
                        Button("Add Player") { showNewPlayerForm = true }
                            .modifier(ProminentGlassButtonModifier())
                            .tint(Theme.fortressBlue)
                    }
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

            VStack(alignment: .leading, spacing: 3) {
                Text(player.fullName.isEmpty ? "Unnamed Player" : player.fullName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                HStack(spacing: 8) {
                    if let number = player.squadNumber {
                        Text("#\(number)")
                    }
                    if player.isGoalkeeper {
                        Text("Goalkeeper")
                    }
                    if let badge = player.captaincyBadge {
                        Text(badge == "C" ? "Captain" : "Vice-Captain")
                    }
                }
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PlayerDatabaseView()
        .environmentObject(PlayerStore())
}
