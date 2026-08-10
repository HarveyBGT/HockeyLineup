import SwiftUI

enum Theme {
    static let cornerRadiusLarge: CGFloat = 24
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 12

    static func pitchGradient(base: Color) -> LinearGradient {
        LinearGradient(
            colors: [base.opacity(0.92), base, base.opacity(0.82)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func accentGradient(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color, color.mix(with: .black, amount: 0.28)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    /// Blends this color toward another by `amount` (0 = self, 1 = target). Used to derive
    /// a darker shade of an arbitrary user-picked team color for gradients, without needing
    /// a design-time palette.
    func mix(with target: Color, amount: Double) -> Color {
        let ui = UIColor(self)
        let targetUI = UIColor(target)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        ui.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        targetUI.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = CGFloat(amount)
        return Color(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t
        )
    }
}

/// Subtle scale + opacity feedback on press, matching the tactile feel of native iOS controls.
struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// A grouped-style card background matching iOS 17's inset-grouped forms.
struct GroupedCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
    }
}

extension View {
    func groupedCard() -> some View {
        modifier(GroupedCardBackground())
    }

    func elevatedShadow() -> some View {
        shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)
    }
}

/// Uses the iOS 26 Liquid Glass prominent button style where available,
/// falling back to the standard bordered-prominent style below that.
struct ProminentGlassButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
    }
}
