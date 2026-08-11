import SwiftUI

/// A flat, low-fidelity shield crest for a `PitchVenue`'s club — same
/// stylised-illustration spirit as `PlayerAvatarView`, not a real badge.
/// Falls back to the club's initials; a couple of clubs get a hand-drawn
/// motif instead (see `ClubMotif`).
struct ClubCrestView: View {
    var crest: ClubCrest
    var size: CGFloat

    private var crestColor: Color { Color(hex: crest.colorHex) }

    var body: some View {
        ZStack {
            ShieldShape()
                .fill(
                    LinearGradient(
                        colors: [crestColor.mix(with: .white, amount: 0.12), crestColor.mix(with: .black, amount: 0.18)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            ShieldShape()
                .stroke(Color.white.opacity(0.35), lineWidth: max(size * 0.02, 1))

            motif
        }
        .frame(width: size, height: size * 1.15)
    }

    @ViewBuilder
    private var motif: some View {
        switch crest.motif {
        case .monogram:
            Text(crest.initials)
                .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.95))

        case .bridge:
            BridgeMotif()
                .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: max(size * 0.045, 1.5), lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.62, height: size * 0.62)
                .offset(y: size * 0.06)

        case .tree:
            TreeMotif()
                .fill(Color.white.opacity(0.92))
                .frame(width: size * 0.5, height: size * 0.58)
                .offset(y: size * 0.02)
        }
    }
}

/// A simple sports-crest silhouette: flat top, straight sides, pointed base.
private struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: h * 0.08))
        path.addLine(to: CGPoint(x: w, y: h * 0.08))
        path.addLine(to: CGPoint(x: w, y: h * 0.55))
        path.addQuadCurve(to: CGPoint(x: w / 2, y: h), control: CGPoint(x: w, y: h * 0.92))
        path.addQuadCurve(to: CGPoint(x: 0, y: h * 0.55), control: CGPoint(x: 0, y: h * 0.92))
        path.closeSubpath()
        return path
    }
}

/// Flat two-pier suspension-bridge silhouette (a nod to Barnes/Dukes Meadow's
/// riverside bridges).
private struct BridgeMotif: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let deckY = h * 0.62

        // Deck.
        path.move(to: CGPoint(x: 0, y: deckY))
        path.addLine(to: CGPoint(x: w, y: deckY))

        // Piers.
        path.move(to: CGPoint(x: w * 0.22, y: 0))
        path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.85))
        path.move(to: CGPoint(x: w * 0.78, y: 0))
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.85))

        // Cables from each pier down to the deck.
        for pierX in [w * 0.22, w * 0.78] {
            for anchorX in [pierX - w * 0.2, pierX + w * 0.2] {
                path.move(to: CGPoint(x: pierX, y: h * 0.18))
                path.addLine(to: CGPoint(x: anchorX, y: deckY))
            }
        }

        return path
    }
}

/// Flat lollipop tree silhouette (canopy + trunk).
private struct TreeMotif: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        let canopyRect = CGRect(x: 0, y: 0, width: w, height: h * 0.72)
        path.addEllipse(in: canopyRect)

        let trunkWidth = w * 0.16
        let trunkRect = CGRect(x: (w - trunkWidth) / 2, y: h * 0.6, width: trunkWidth, height: h * 0.4)
        path.addRoundedRect(in: trunkRect, cornerSize: CGSize(width: trunkWidth * 0.3, height: trunkWidth * 0.3))

        return path
    }
}

#Preview {
    HStack(spacing: 16) {
        ClubCrestView(crest: PitchVenue.venue(id: "barnes").crest, size: 60)
        ClubCrestView(crest: PitchVenue.venue(id: "teddington").crest, size: 60)
        ClubCrestView(crest: PitchVenue.venue(id: "surbiton").crest, size: 60)
        ClubCrestView(crest: ClubCrest.forTeamName("Old Tonbridgians M1"), size: 60)
    }
    .padding()
}
