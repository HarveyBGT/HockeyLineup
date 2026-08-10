import SwiftUI

/// Draws a `PlayerAvatar` as a simple, flat, sticker-style face — used
/// anywhere a player's identity is shown, in place of an uploaded photo.
struct PlayerAvatarView: View {
    var avatar: PlayerAvatar
    var size: CGFloat

    private var skinColor: Color { Color(hex: avatar.skinToneHex) }
    private var hairColor: Color { Color(hex: avatar.hairColorHex) }

    var body: some View {
        ZStack {
            if avatar.hairStyle == .afro {
                Circle()
                    .fill(hairColor)
                    .frame(width: size * 1.2, height: size * 1.2)
            }

            Circle()
                .fill(skinColor)
                .frame(width: size, height: size)
                .overlay(face)
                .overlay(hairOverlay.clipShape(Circle()))
        }
        .frame(width: size * 1.2, height: size * 1.2)
    }

    @ViewBuilder
    private var face: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                HStack(spacing: w * 0.22) {
                    Circle().frame(width: w * 0.09, height: w * 0.09)
                    Circle().frame(width: w * 0.09, height: w * 0.09)
                }
                .foregroundColor(.black.opacity(0.78))
                .position(x: w * 0.5, y: h * 0.52)

                Capsule()
                    .fill(Color.black.opacity(0.42))
                    .frame(width: w * 0.22, height: max(h * 0.035, 1.5))
                    .position(x: w * 0.5, y: h * 0.68)

                if avatar.wearsGlasses {
                    HStack(spacing: w * 0.06) {
                        RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.75), lineWidth: 1.6)
                            .frame(width: w * 0.2, height: w * 0.15)
                        RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.75), lineWidth: 1.6)
                            .frame(width: w * 0.2, height: w * 0.15)
                    }
                    .position(x: w * 0.5, y: h * 0.52)
                }
            }
        }
    }

    @ViewBuilder
    private var hairOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            switch avatar.hairStyle {
            case .bald, .afro:
                EmptyView()

            case .short:
                Path { path in
                    path.addArc(center: CGPoint(x: w / 2, y: h * 0.4), radius: w * 0.54, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.closeSubpath()
                }
                .fill(hairColor)

            case .long:
                ZStack {
                    Path { path in
                        path.addArc(center: CGPoint(x: w / 2, y: h * 0.34), radius: w * 0.56, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                        path.addLine(to: CGPoint(x: w, y: 0))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                        path.closeSubpath()
                    }
                    RoundedRectangle(cornerRadius: w * 0.12)
                        .frame(width: w * 0.22, height: h * 0.62)
                        .position(x: w * 0.1, y: h * 0.55)
                    RoundedRectangle(cornerRadius: w * 0.12)
                        .frame(width: w * 0.22, height: h * 0.62)
                        .position(x: w * 0.9, y: h * 0.55)
                }
                .foregroundColor(hairColor)

            case .curly:
                ZStack {
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .frame(width: w * 0.28, height: w * 0.28)
                            .position(x: w * (0.1 + Double(i) * 0.16), y: h * 0.16)
                    }
                }
                .foregroundColor(hairColor)
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        PlayerAvatarView(avatar: PlayerAvatar(skinToneHex: PlayerAvatar.skinTones[1], hairStyle: .curly, hairColorHex: PlayerAvatar.hairColors[1], wearsGlasses: true), size: 80)
        PlayerAvatarView(avatar: PlayerAvatar(skinToneHex: PlayerAvatar.skinTones[4], hairStyle: .afro, hairColorHex: PlayerAvatar.hairColors[0]), size: 80)
        PlayerAvatarView(avatar: PlayerAvatar(skinToneHex: PlayerAvatar.skinTones[0], hairStyle: .long, hairColorHex: PlayerAvatar.hairColors[3]), size: 80)
        PlayerAvatarView(avatar: PlayerAvatar(skinToneHex: PlayerAvatar.skinTones[5], hairStyle: .bald), size: 80)
    }
    .padding()
}
