import SwiftUI

/// Presented when tapping an empty or filled pitch position. Lets the user
/// assign an existing player from the squad database, create a brand new
/// one, or clear the slot.
struct PlayerPickerView: View {
    var positionRole: PositionRole
    var currentPlayerID: UUID?
    var onSelect: (UUID?) -> Void

    @EnvironmentObject private var playerStore: PlayerStore
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var showNewPlayerForm = false

    private var filteredPlayers: [Player] {
        let sorted = playerStore.players.sorted { $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showNewPlayerForm = true
                    } label: {
                        Label("Create New Player", systemImage: "person.badge.plus")
                    }

                    if currentPlayerID != nil {
                        Button(role: .destructive) {
                            onSelect(nil)
                            dismiss()
                        } label: {
                            Label("Remove From Position", systemImage: "xmark.circle")
                        }
                    }
                }

                Section("Squad") {
                    if filteredPlayers.isEmpty {
                        Text(playerStore.players.isEmpty ? "No players yet — create one above." : "No matches.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(filteredPlayers) { player in
                        Button {
                            onSelect(player.id)
                            dismiss()
                        } label: {
                            PlayerRow(player: player, isSelected: player.id == currentPlayerID, suggested: positionRole == .goalkeeper && player.isGoalkeeper)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search players")
            .navigationTitle("Choose Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showNewPlayerForm) {
                PlayerFormView(existingPlayer: Player(isGoalkeeper: positionRole == .goalkeeper)) { newPlayer in
                    playerStore.upsert(newPlayer)
                    onSelect(newPlayer.id)
                    dismiss()
                }
            }
        }
    }
}

private struct PlayerRow: View {
    var player: Player
    var isSelected: Bool
    var suggested: Bool

    var body: some View {
        HStack(spacing: 12) {
            PlayerAvatarView(avatar: player.avatar, size: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(player.fullName.isEmpty ? "Unnamed Player" : player.fullName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                HStack(spacing: 6) {
                    if let number = player.squadNumber {
                        Text("#\(number)")
                    }
                    if player.isGoalkeeper {
                        Text("GK")
                    }
                    if let badge = player.captaincyBadge {
                        Text(badge)
                    }
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }

            Spacer()

            if suggested {
                Text("Suggested")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    PlayerPickerView(positionRole: .forward, currentPlayerID: nil) { _ in }
        .environmentObject(PlayerStore())
}
