import WidgetKit
import SwiftUI

/// A watch face complication showing the next fixture. Separate compilation
/// unit from the iOS widget (different target, different platform) — reads
/// the same static `LeagueData`/`PitchVenue` seed data, but redefines its own
/// small timeline types rather than sharing code cross-target.
struct WatchFixtureEntry: TimelineEntry {
    let date: Date
    let fixture: Fixture?
}

struct NextFixtureComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchFixtureEntry {
        WatchFixtureEntry(date: Date(), fixture: LeagueData.fixtures(forTeamID: MyTeam.teamID).first)
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchFixtureEntry) -> Void) {
        completion(WatchFixtureEntry(date: Date(), fixture: nextFixture()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchFixtureEntry>) -> Void) {
        let entry = WatchFixtureEntry(date: Date(), fixture: nextFixture())
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(86_400)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func nextFixture() -> Fixture? {
        let now = Date()
        return LeagueData.fixtures(forTeamID: MyTeam.teamID).first { $0.date >= now }
    }
}

struct NextFixtureComplicationView: View {
    @Environment(\.widgetFamily) private var family
    var entry: WatchFixtureEntry

    var body: some View {
        if let fixture = entry.fixture {
            let opponentName = LeagueData.team(id: fixture.opponentID(for: MyTeam.teamID))?.name ?? "TBC"
            switch family {
            case .accessoryCircular:
                circular
            case .accessoryInline:
                Text("vs \(opponentName) \(Self.shortDateFormatter.string(from: fixture.date))")
            default:
                rectangular(opponentName: opponentName, fixture: fixture)
            }
        } else {
            Text("No fixtures")
        }
    }

    private var circular: some View {
        VStack(spacing: 1) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 14))
            Text("NEXT")
                .font(.system(size: 8, weight: .bold))
        }
        .widgetAccentable()
    }

    private func rectangular(opponentName: String, fixture: Fixture) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("vs \(opponentName)")
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
            Text("\(Self.shortDateFormatter.string(from: fixture.date)) · \(Self.timeFormatter.string(from: fixture.date))")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

struct NextFixtureComplication: Widget {
    let kind = "NextFixtureComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextFixtureComplicationProvider()) { entry in
            NextFixtureComplicationView(entry: entry)
        }
        .configurationDisplayName("Next Fixture")
        .description("Barnes M3's next upcoming match.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

#Preview(as: .accessoryRectangular) {
    NextFixtureComplication()
} timeline: {
    WatchFixtureEntry(date: Date(), fixture: LeagueData.fixtures(forTeamID: MyTeam.teamID).first)
}
