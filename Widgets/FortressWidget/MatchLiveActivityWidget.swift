import ActivityKit
import WidgetKit
import SwiftUI

struct MatchLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MatchActivityAttributes.self) { context in
            bannerView(context: context)
                .activityBackgroundTint(Theme.stoneDark)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    scoreColumn(title: MyTeam.name, score: context.state.ourScore, alignment: .leading)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    scoreColumn(title: context.attributes.opponentName, score: context.state.opponentScore, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.statusText)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.venueText)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } compactLeading: {
                Text("\(context.state.ourScore)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } compactTrailing: {
                Text("\(context.state.opponentScore)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } minimal: {
                Text("\(context.state.ourScore)-\(context.state.opponentScore)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }

    private func bannerView(context: ActivityViewContext<MatchActivityAttributes>) -> some View {
        HStack(spacing: 16) {
            scoreColumn(title: MyTeam.name, score: context.state.ourScore, alignment: .leading)
            VStack(spacing: 2) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 14))
                Text(context.state.statusText)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.7))
            scoreColumn(title: context.attributes.opponentName, score: context.state.opponentScore, alignment: .trailing)
        }
        .padding(16)
    }

    private func scoreColumn(title: String, score: Int, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
            Text("\(score)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
    }
}
