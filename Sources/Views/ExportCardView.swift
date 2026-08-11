import SwiftUI
import UIKit

/// Non-interactive view styled specifically for rendering to a shareable image.
/// Composed as a card floating on a neutral backdrop, in the spirit of Apple's
/// own share-card layouts (Music Replay, Fitness+) — the team's own colour
/// carries the design, framed by generous negative space.
struct ExportCardView: View {
    var card: LineupCard
    var playerStore: PlayerStore

    private var color: Color { Color(hex: card.activeColorHex) }

    private var benchPlayers: [Player] {
        card.benchPlayerIDs.compactMap { $0 }.compactMap { playerStore.player(id: $0) }
    }

    private var officialsLines: [String] {
        var lines: [String] = []
        let coach = card.coachName.trimmingCharacters(in: .whitespaces)
        if !coach.isEmpty { lines.append("Coach: \(coach)") }
        let umpires = [card.umpireOneName, card.umpireTwoName]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        if !umpires.isEmpty { lines.append("Umpires: \(umpires.joined(separator: ", "))") }
        return lines
    }

    private var hasBenchOrOfficials: Bool { !benchPlayers.isEmpty || !officialsLines.isEmpty }

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ClubCrestView(crest: card.myCrest, size: 40)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(card.clubName.isEmpty ? "Hockey Club" : card.clubName)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        if !card.matchSummaryText.isEmpty {
                            Text(card.matchSummaryText)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.82))
                        }
                    }
                    Spacer()

                    Text(card.formation.name)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.18), in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
                }
                .padding(18)
                .background(Theme.accentGradient(color))

                PitchView(
                    formation: card.formation,
                    playerIDs: .constant(card.playerIDs),
                    playerStore: playerStore,
                    accentColor: color,
                    pitchColor: Color(hex: card.pitchVenue.colorHex),
                    interactive: false
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge, style: .continuous))
            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 14)

            if hasBenchOrOfficials {
                VStack(alignment: .leading, spacing: 12) {
                    if !benchPlayers.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BENCH")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1.2)
                                .foregroundColor(.white.opacity(0.5))

                            HStack(spacing: 14) {
                                ForEach(benchPlayers) { player in
                                    VStack(spacing: 4) {
                                        PlayerAvatarView(avatar: player.avatar, size: 28)
                                        Text(player.lastName.isEmpty ? player.firstName : player.lastName)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.white.opacity(0.85))
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }

                    if !officialsLines.isEmpty {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(officialsLines, id: \.self) { line in
                                Text(line)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 5) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 10, weight: .semibold))
                Text("FORTRESS XI")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(1.2)
            }
            .foregroundColor(.white.opacity(0.4))
        }
        .padding(26)
        .frame(width: 400)
        .background(
            LinearGradient(colors: [Color(hex: "#101114"), Color(hex: "#0A0A0C")], startPoint: .top, endPoint: .bottom)
        )
    }
}

#Preview {
    ExportCardView(card: LineupCard(formation: Formation.presets[0]), playerStore: PlayerStore())
}
