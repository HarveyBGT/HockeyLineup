import SwiftUI

/// Bench slots plus coach/umpire names.
struct SuperSubsSection: View {
    @Binding var card: LineupCard
    var playerStore: PlayerStore
    var accentColor: Color
    @Binding var benchDragTargetIndex: Int?
    var onEditBenchIndex: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Super Subs")
                .font(.system(size: 15, weight: .medium))

            HStack(spacing: 10) {
                ForEach(card.benchPlayerIDs.indices, id: \.self) { index in
                    BenchSlotView(
                        player: playerStore.player(id: card.benchPlayerIDs[index]),
                        accentColor: accentColor,
                        isDropTarget: benchDragTargetIndex == index
                    )
                    .onTapGesture { onEditBenchIndex(index) }
                    .onDrag {
                        NSItemProvider(object: NSString(string: PlayerSlot.bench(index).dragPayload))
                    }
                    .dropDestination(for: String.self) { items, _ in
                        benchDragTargetIndex = nil
                        guard let payload = items.first, let sourceSlot = PlayerSlot(dragPayload: payload) else { return false }
                        card.swapOrMove(from: sourceSlot, to: .bench(index))
                        return true
                    } isTargeted: { targeted in
                        benchDragTargetIndex = targeted ? index : nil
                    }
                }
            }

            Divider()

            HStack {
                Label("Coach", systemImage: "person.fill.checkmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer()
                TextField("Name", text: $card.coachName)
                    .multilineTextAlignment(.trailing)
            }

            Divider()

            HStack {
                Label("Umpire 1", systemImage: "flag.checkered")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer()
                TextField("Name", text: $card.umpireOneName)
                    .multilineTextAlignment(.trailing)
            }

            Divider()

            HStack {
                Label("Umpire 2", systemImage: "flag.checkered")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer()
                TextField("Name", text: $card.umpireTwoName)
                    .multilineTextAlignment(.trailing)
            }
        }
        .groupedCard()
        .padding(.horizontal, 16)
    }
}

/// A single optional bench-squad slot: empty state invites a tap, filled
/// state shows the player's avatar and surname.
private struct BenchSlotView: View {
    var player: Player?
    var accentColor: Color
    var isDropTarget: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(player == nil ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Theme.accentGradient(accentColor)))
                .frame(width: 40, height: 40)
                .overlay {
                    if let player {
                        PlayerAvatarView(avatar: player.avatar, size: 32)
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .overlay(Circle().stroke(Color(.separator), lineWidth: 1))
                .overlay(
                    Circle()
                        .stroke(Theme.fortressGold, lineWidth: 3)
                        .padding(-4)
                        .opacity(isDropTarget ? 1 : 0)
                )
                .scaleEffect(isDropTarget ? 1.12 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDropTarget)

            Text(player?.lastName.isEmpty == false ? (player?.lastName ?? "—") : "—")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
