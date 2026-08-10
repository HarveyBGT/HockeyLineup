import SwiftUI

/// Draws a simplified field-hockey pitch: halfway line, 23m lines, and the
/// two shooting circles ("the D") at each end. Attack direction is up.
struct PitchMarkingsView: View {
    var baseColor: Color = Color(hex: "#1E7A46")

    var body: some View {
        Canvas { context, size in
            let lineColor = Color.white.opacity(0.9)
            let inset: CGFloat = size.width * 0.045

            let field = CGRect(x: inset, y: inset, width: size.width - inset * 2, height: size.height - inset * 2)

            // Alternating mow stripes for a pitch-like texture.
            let stripeCount = 12
            let stripeHeight = field.height / CGFloat(stripeCount)
            for i in 0..<stripeCount {
                if i % 2 == 0 {
                    let stripeRect = CGRect(x: field.minX, y: field.minY + CGFloat(i) * stripeHeight, width: field.width, height: stripeHeight)
                    context.fill(Path(stripeRect), with: .color(Color.white.opacity(0.035)))
                }
            }

            // Boundary, rounded to feel less like a technical diagram.
            let boundary = Path(roundedRect: field, cornerRadius: field.width * 0.02)
            context.stroke(boundary, with: .color(lineColor), lineWidth: 2.5)

            // Halfway line.
            var halfway = Path()
            halfway.move(to: CGPoint(x: field.minX, y: field.midY))
            halfway.addLine(to: CGPoint(x: field.maxX, y: field.midY))
            context.stroke(halfway, with: .color(lineColor.opacity(0.8)), lineWidth: 1.5)

            // 23m lines (dashed), one nearer each backline.
            for fraction: CGFloat in [0.25, 0.75] {
                var line = Path()
                let y = field.minY + field.height * fraction
                line.move(to: CGPoint(x: field.minX, y: y))
                line.addLine(to: CGPoint(x: field.maxX, y: y))
                context.stroke(line, with: .color(lineColor.opacity(0.7)), style: StrokeStyle(lineWidth: 1.5, dash: [7, 6]))
            }

            // Shooting circles ("the D") at each end.
            let radius = field.width * 0.30
            for edgeY in [field.minY, field.maxY] {
                var arc = Path()
                let center = CGPoint(x: field.midX, y: edgeY)
                let startAngle: Angle = edgeY == field.minY ? .degrees(0) : .degrees(180)
                let endAngle: Angle = edgeY == field.minY ? .degrees(180) : .degrees(360)
                arc.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                context.stroke(arc, with: .color(lineColor.opacity(0.85)), lineWidth: 1.5)
            }

            // Goals.
            let goalWidth = field.width * 0.12
            let goalDepth = size.height * 0.016
            let topGoal = CGRect(x: field.midX - goalWidth / 2, y: field.minY - goalDepth, width: goalWidth, height: goalDepth)
            let bottomGoal = CGRect(x: field.midX - goalWidth / 2, y: field.maxY, width: goalWidth, height: goalDepth)
            context.stroke(Path(topGoal), with: .color(lineColor), lineWidth: 2)
            context.stroke(Path(bottomGoal), with: .color(lineColor), lineWidth: 2)

            // Soft vignette for depth.
            let vignette = Gradient(stops: [
                .init(color: .clear, location: 0.6),
                .init(color: .black.opacity(0.16), location: 1)
            ])
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .radialGradient(vignette, center: CGPoint(x: size.width / 2, y: size.height / 2), startRadius: size.width * 0.3, endRadius: size.width * 0.85)
            )
        }
        .background(Theme.pitchGradient(base: baseColor))
    }
}

#Preview {
    PitchMarkingsView()
        .frame(width: 360, height: 520)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
}
