import SwiftUI

/// Starts/updates/ends a Live Activity for the match — the view is a thin
/// shell over `MatchActivityController`, which owns the actual ActivityKit
/// lifecycle and score/status state.
struct MatchDaySection: View {
    @Binding var card: LineupCard
    @ObservedObject var activity: MatchActivityController

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Match Day", systemImage: "dot.radiowaves.left.and.right")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                if activity.isLive {
                    Text("LIVE")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(0.5)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.red, in: Capsule())
                }
            }

            if !activity.isLive {
                Button {
                    startLiveActivity()
                } label: {
                    Label("Start Live Activity", systemImage: "play.circle.fill")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .modifier(ProminentGlassButtonModifier())
                .disabled(card.opposition.isEmpty)

                if card.opposition.isEmpty {
                    Text("Set an opposition to start a Live Activity.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack(spacing: 16) {
                    liveScoreCounter(title: MyTeam.name, value: activity.ourScore) { activity.adjustOurScore(by: $0) }
                    Text("–")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    liveScoreCounter(title: card.opposition, value: activity.opponentScore) { activity.adjustOpponentScore(by: $0) }
                }

                Picker("Status", selection: Binding(get: { activity.status }, set: { activity.setStatus($0) })) {
                    ForEach(MatchActivityController.statusOptions, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)

                Button(role: .destructive) {
                    endLiveActivity()
                } label: {
                    Label("End Live Activity", systemImage: "stop.circle.fill")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
        }
        .groupedCard()
        .padding(.horizontal, 16)
    }

    private func startLiveActivity() {
        let initialOurScore = card.isHome ? (card.homeScore ?? 0) : (card.awayScore ?? 0)
        let initialOpponentScore = card.isHome ? (card.awayScore ?? 0) : (card.homeScore ?? 0)
        activity.start(
            opponentName: card.opposition,
            isHome: card.isHome,
            venueText: card.venueText,
            initialOurScore: initialOurScore,
            initialOpponentScore: initialOpponentScore
        )
    }

    private func endLiveActivity() {
        guard let final = activity.end() else { return }
        card.recordResult(ourScore: final.ourScore, opponentScore: final.opponentScore)
    }

    private func liveScoreCounter(title: String, value: Int, onChange: @escaping (Int) -> Void) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            HStack(spacing: 10) {
                Button { onChange(-1) } label: {
                    Image(systemName: "minus.circle.fill")
                }
                Text("\(value)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .frame(minWidth: 28)
                Button { onChange(1) } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .font(.system(size: 20))
            .foregroundStyle(Theme.fortressBlue)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
