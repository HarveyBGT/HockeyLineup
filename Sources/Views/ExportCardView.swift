import SwiftUI
import UIKit

/// Non-interactive view styled specifically for rendering to a shareable image.
/// Composed as a card floating on a neutral backdrop, in the spirit of Apple's
/// own share-card layouts (Music Replay, Fitness+) — the team's own colour
/// carries the design, framed by generous negative space.
struct ExportCardView: View {
    var card: LineupCard
    var playerStore: PlayerStore

    private var color: Color { Color(hex: card.colorHex) }

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    if let data = card.logoImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 46)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.white.opacity(0.25), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(card.clubName.isEmpty ? "Hockey Club" : card.clubName)
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        if !card.matchSubtitle.isEmpty {
                            Text(card.matchSubtitle)
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

            HStack(spacing: 5) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 10, weight: .semibold))
                Text("HOCKEY LINEUP")
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
