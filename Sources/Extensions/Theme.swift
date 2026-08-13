import SwiftUI

/// The Fortress design language: named after Dukes Meadow's nickname among
/// Barnes HC players and supporters. Barnes blue as the primary identity
/// colour (their real kit/pitch colour), a bronze/gold heraldic accent for
/// premium touches (captaincy, crest trim), and stone neutrals for chrome.
enum Theme {
    static let cornerRadiusLarge: CGFloat = 24
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 12

    /// Barnes' confirmed real kit/pitch colour — the app's primary identity.
    static let fortressBlue = Color(hex: "#1C63A8")
    /// Heraldic bronze/gold accent for premium touches: captaincy, crest trim.
    static let fortressGold = Color(hex: "#C9962C")
    /// Deep stone-navy, used for dark chrome (crest shields, export backdrops).
    static let stoneDark = Color(hex: "#0B2545")

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

    static func resultColor(_ result: MatchResult) -> Color {
        switch result {
        case .win: return .green
        case .draw: return .orange
        case .loss: return .red
        }
    }

    /// A contained band of rich brand colour to sit behind the pitch and
    /// primary actions — Liquid Glass reads as a subtle grey smear over a
    /// flat system background, but genuinely refracts and throws specular
    /// highlights over something with actual colour and depth in it.
    /// Concrete `LinearGradient`, not `some View` — needs to work as a
    /// `ShapeStyle` for `.fill(...)`.
    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [stoneDark, fortressBlue.mix(with: .black, amount: 0.1), stoneDark.mix(with: fortressGold, amount: 0.08)],
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

/// A grouped-style card background: real Liquid Glass on iOS 26 (dynamic
/// refraction, specular highlights, morphs smoothly on tap), an inset-grouped
/// forms fill below that.
struct GroupedCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .padding(16)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous))
        } else {
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
        }
    }
}

/// A glassy variant of `GroupedCardBackground` tinted with the club's active
/// colour — for surfaces that should read as "part of the brand" rather than
/// neutral chrome (lineup rows, the pitch card frame).
struct TintedGlassCardBackground: ViewModifier {
    var tint: Color
    var cornerRadius: CGFloat = Theme.cornerRadiusMedium

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.tint(tint.opacity(0.5)), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            content.background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }
}

extension View {
    func groupedCard() -> some View {
        modifier(GroupedCardBackground())
    }

    func tintedGlassCard(tint: Color, cornerRadius: CGFloat = Theme.cornerRadiusMedium) -> some View {
        modifier(TintedGlassCardBackground(tint: tint, cornerRadius: cornerRadius))
    }

    func elevatedShadow() -> some View {
        shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)
    }
}

/// A small circular glass affordance — empty player slots, icon badges —
/// real glass on iOS 26, `.ultraThinMaterial` below that.
struct GlassCircleBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: .circle)
        } else {
            content.background(.ultraThinMaterial, in: .circle)
        }
    }
}

extension View {
    func glassCircle() -> some View {
        modifier(GlassCircleBackground())
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

/// A single pill in a hand-rolled two-option glass toggle (e.g. Home/Away):
/// tinted glass when selected, plain glass otherwise, on iOS 26; a solid
/// fill/fill-less fallback below that.
struct GlassTogglePillBackground: ViewModifier {
    var isSelected: Bool
    var tint: Color

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(isSelected ? .regular.tint(tint) : .regular, in: .capsule)
        } else {
            content.background(
                isSelected ? AnyShapeStyle(tint) : AnyShapeStyle(Color(.tertiarySystemFill)),
                in: Capsule()
            )
        }
    }
}
