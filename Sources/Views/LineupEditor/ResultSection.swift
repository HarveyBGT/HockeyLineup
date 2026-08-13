import SwiftUI

/// Final score entry and the resulting win/draw/loss badge.
struct ResultSection: View {
    @Binding var card: LineupCard

    private var homeScoreBinding: Binding<String> {
        Binding(
            get: { card.homeScore.map(String.init) ?? "" },
            set: { card.homeScore = Int($0) }
        )
    }

    private var awayScoreBinding: Binding<String> {
        Binding(
            get: { card.awayScore.map(String.init) ?? "" },
            set: { card.awayScore = Int($0) }
        )
    }

    private var homeScoreFieldLabel: String {
        card.isHome ? MyTeam.name : (card.opposition.isEmpty ? "Home" : card.opposition)
    }

    private var awayScoreFieldLabel: String {
        card.isHome ? (card.opposition.isEmpty ? "Away" : card.opposition) : MyTeam.name
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Result")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                if let result = card.result {
                    Text(result.label.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(0.5)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.resultColor(result), in: Capsule())
                }
            }

            HStack(spacing: 14) {
                scoreField(title: homeScoreFieldLabel, text: homeScoreBinding)
                Text("–")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                scoreField(title: awayScoreFieldLabel, text: awayScoreBinding)
                Spacer()
            }
        }
        .groupedCard()
        .padding(.horizontal, 16)
    }

    private func scoreField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            TextField("–", text: text)
                .keyboardType(.numberPad)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(width: 44)
        }
    }
}
