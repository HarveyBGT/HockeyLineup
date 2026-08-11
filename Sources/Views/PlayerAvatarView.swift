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
                .overlay(beardOverlay.clipShape(Circle()))
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
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                            .frame(width: w * 0.09, height: max(w * 0.026, 1.6))

                        HStack(spacing: w * 0.09) {
                            lens(w: w)
                            lens(w: w)
                        }
                    }
                    .position(x: w * 0.5, y: h * 0.52)
                }
            }
        }
    }

    private func lens(w: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: w * 0.045, style: .continuous)
            .fill(Color.white.opacity(0.16))
            .frame(width: w * 0.25, height: w * 0.19)
            .overlay(
                RoundedRectangle(cornerRadius: w * 0.045, style: .continuous)
                    .stroke(Color.black.opacity(0.82), lineWidth: max(w * 0.026, 1.6))
            )
    }

    @ViewBuilder
    private var beardOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            switch avatar.beardStyle {
            case .none:
                EmptyView()

            case .stubble:
                Ellipse()
                    .fill(hairColor.opacity(0.4))
                    .frame(width: w * 0.62, height: h * 0.36)
                    .position(x: w * 0.5, y: h * 0.84)

            case .goatee:
                RoundedRectangle(cornerRadius: w * 0.09)
                    .fill(hairColor)
                    .frame(width: w * 0.22, height: h * 0.3)
                    .position(x: w * 0.5, y: h * 0.9)

            case .full:
                Ellipse()
                    .fill(hairColor)
                    .frame(width: w * 0.74, height: h * 0.48)
                    .position(x: w * 0.5, y: h * 0.88)
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
                // A rectangle spanning the top of the frame, rounded off by the
                // circular clip applied where this view is used — reads as a cap.
                Rectangle()
                    .frame(width: w, height: h * 0.4)
                    .position(x: w / 2, y: h * 0.2)
                    .foregroundColor(hairColor)

            case .long:
                ZStack {
                    Rectangle()
                        .frame(width: w, height: h * 0.42)
                        .position(x: w / 2, y: h * 0.21)
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
