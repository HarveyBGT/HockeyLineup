import SwiftUI
import UniformTypeIdentifiers

struct PitchView: View {
    var formation: Formation
    @Binding var playerIDs: [UUID?]
    var playerStore: PlayerStore
    var accentColor: Color
    var pitchColor: Color = Color(hex: "#1E7A46")
    var interactive: Bool = true

    @State private var editingIndex: Int? = nil

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
                        accentColor: accentColor
                    )
                    .position(point)
                    .onTapGesture {
                        guard interactive else { return }
                        editingIndex = position.id
                    }
                    .onDrag {
                        NSItemProvider(object: NSString(string: "\(position.id)"))
                    }
                    .onDrop(of: [.text], isTargeted: nil) { providers in
                        guard interactive, let provider = providers.first else { return false }
                        _ = provider.loadObject(ofClass: NSString.self) { reading, _ in
                            guard let sourceString = reading as? NSString, let sourceIndex = Int(sourceString as String) else { return }
                            DispatchQueue.main.async {
                                swap(sourceIndex: sourceIndex, targetIndex: position.id)
                            }
                        }
                        return true
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
                    currentPlayerID: playerIDs.indices.contains(index) ? playerIDs[index] : nil
                ) { selectedID in
                    if playerIDs.indices.contains(index) {
                        playerIDs[index] = selectedID
                    }
                }
            }
        }
    }

    private func swap(sourceIndex: Int, targetIndex: Int) {
        guard sourceIndex != targetIndex,
              playerIDs.indices.contains(sourceIndex),
              playerIDs.indices.contains(targetIndex) else { return }
        playerIDs.swapAt(sourceIndex, targetIndex)
    }
}

private struct PositionDotView: View {
    var role: PositionRole
    var player: Player?
    var accentColor: Color

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(player == nil ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Theme.accentGradient(accentColor)))

                if let player {
                    PlayerAvatarView(avatar: player.avatar, size: 30)
                } else {
                    Text(role.rawValue)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Circle()
                    .stroke(Color.white.opacity(player == nil ? 0.6 : 0.95), lineWidth: 2)

                if let number = player?.squadNumber {
                    badge(text: "\(number)", color: .black.opacity(0.75))
                        .offset(x: -16, y: -16)
                }
                if let captaincyBadge = player?.captaincyBadge {
                    badge(text: captaincyBadge, color: Color(hex: "#C9962C"))
                        .offset(x: 16, y: -16)
                }
            }
            .frame(width: 36, height: 36)
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
