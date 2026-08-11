import SwiftUI

struct PitchView: View {
    var formation: Formation
    @Binding var playerIDs: [UUID?]
    var playerStore: PlayerStore
    var accentColor: Color
    var pitchColor: Color = Color(hex: "#1E7A46")
    var interactive: Bool = true
    /// Short label ("On bench", "On pitch — DEF") for a player who's already
    /// placed somewhere other than the pitch position currently being
    /// edited, so the picker can show it and picking them anyway moves them.
    var slotLabel: (Int, UUID) -> String? = { _, _ in nil }
    /// Called when a player is picked for pitch position `index` — routes
    /// through `LineupCard.assign` so the player is vacated from wherever
    /// else they were placed instead of appearing in two spots.
    var onAssign: (Int, UUID?) -> Void = { _, _ in }
    /// Called when a position is dragged onto another (pitch or bench) —
    /// routes through `LineupCard.swapOrMove` so the two slots trade places.
    var onSwap: (PlayerSlot, PlayerSlot) -> Void = { _, _ in }

    @State private var editingIndex: Int? = nil
    @State private var dragTargetIndex: Int? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                PitchMarkingsView(baseColor: pitchColor)

                ForEach(formation.positions) { position in
                    let point = CGPoint(
                        x: geo.size.width * position.x,
                        y: geo.size.height * (1 - position.y)
                    )
                    let player = playerIDs.indices.contains(position.id) ? playerStore.player(id: playerIDs[position.id]) : nil

                    PositionDotView(
                        role: position.role,
                        player: player,
                        accentColor: accentColor,
                        isDropTarget: dragTargetIndex == position.id
                    )
                    .position(point)
                    .onTapGesture {
                        guard interactive else { return }
                        editingIndex = position.id
                    }
                    .onDrag {
                        NSItemProvider(object: NSString(string: PlayerSlot.pitch(position.id).dragPayload))
                    }
                    .dropDestination(for: String.self) { items, _ in
                        dragTargetIndex = nil
                        guard interactive, let payload = items.first,
                              let sourceSlot = PlayerSlot(dragPayload: payload) else { return false }
                        onSwap(sourceSlot, .pitch(position.id))
                        return true
                    } isTargeted: { targeted in
                        dragTargetIndex = targeted ? position.id : nil
                    }
                }
            }
        }
        .aspectRatio(0.7, contentMode: .fit)
        .sheet(isPresented: Binding(
            get: { editingIndex != nil },
            set: { if !$0 { editingIndex = nil } }
        )) {
            if let index = editingIndex {
                PlayerPickerView(
                    positionRole: formation.positions.first(where: { $0.id == index })?.role ?? .midfield,
                    currentPlayerID: playerIDs.indices.contains(index) ? playerIDs[index] : nil,
                    slotLabel: { playerID in slotLabel(index, playerID) }
                ) { selectedID in
                    onAssign(index, selectedID)
                }
            }
        }
    }
}

private struct PositionDotView: View {
    var role: PositionRole
    var player: Player?
    var accentColor: Color
    var isDropTarget: Bool = false

    // Head sits at the top of the frame; the shoulders (kit colour) are a
    // capsule that starts partway up the head so they read as "worn" rather
    // than floating separately.
    private let headSize: CGFloat = 34
    private let shoulderWidth: CGFloat = 40
    private let shoulderHeight: CGFloat = 18
    private let shoulderTopOffset: CGFloat = 24

    var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: .top) {
                if player != nil {
                    Capsule()
                        .fill(Theme.accentGradient(accentColor))
                        .frame(width: shoulderWidth, height: shoulderHeight)
                        .offset(y: shoulderTopOffset)
                }

                Circle()
                    .fill(player == nil ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Theme.accentGradient(accentColor)))
                    .frame(width: headSize, height: headSize)
                    .overlay {
                        if let player {
                            PlayerAvatarView(avatar: player.avatar, size: headSize * 0.82)
                        } else {
                            Text(role.rawValue)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .overlay(Circle().stroke(Color.white.opacity(player == nil ? 0.6 : 0.95), lineWidth: 2))
                    .overlay(
                        Circle()
                            .stroke(Theme.fortressGold, lineWidth: 3)
                            .padding(-4)
                            .opacity(isDropTarget ? 1 : 0)
                    )
                    .scaleEffect(isDropTarget ? 1.12 : 1)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDropTarget)

                if let number = player?.squadNumber {
                    badge(text: "\(number)", color: .black.opacity(0.75))
                        .offset(x: -15, y: -1)
                }
                if let captaincyBadge = player?.captaincyBadge {
                    badge(text: captaincyBadge, color: Theme.fortressGold)
                        .offset(x: 15, y: -1)
                }
            }
            .frame(width: shoulderWidth, height: shoulderTopOffset + shoulderHeight, alignment: .top)
            .shadow(color: .black.opacity(0.28), radius: 4, x: 0, y: 2)

            if let player, !player.fullName.isEmpty {
                Text(player.fullName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.5), in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5))
                    .fixedSize()
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: player)
    }

    private func badge(text: String, color: Color) -> some View {
        let label = Text(text)
            .font(.system(size: 8, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(3)
            .frame(minWidth: 15, minHeight: 15)

        return Group {
            if #available(iOS 26.0, *) {
                label.glassEffect(.regular.tint(color), in: .circle)
            } else {
                label
                    .background(color, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1))
            }
        }
    }
}
