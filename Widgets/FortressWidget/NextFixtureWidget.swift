import WidgetKit
import SwiftUI

/// Shows Barnes M3's next upcoming fixture — opposition, kick-off, home/away,
/// and venue — straight from `LeagueData`'s seed data. Deliberately doesn't
/// read the app's saved lineups (no App Group / shared container needed),
/// so this works the moment the widget's added, with no extra setup beyond
/// what any widget extension already needs.
struct FixtureEntry: TimelineEntry {
    let date: Date
    let fixture: Fixture?
}

struct NextFixtureProvider: TimelineProvider {
    func placeholder(in context: Context) -> FixtureEntry {
        FixtureEntry(date: Date(), fixture: LeagueData.fixtures(forTeamID: MyTeam.teamID).first)
    }

    func getSnapshot(in context: Context, completion: @escaping (FixtureEntry) -> Void) {
        completion(FixtureEntry(date: Date(), fixture: nextFixture()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FixtureEntry>) -> Void) {
        let entry = FixtureEntry(date: Date(), fixture: nextFixture())
        // The fixture list is static seed data baked into the app, so
        // there's nothing to gain from refreshing more than once a day —
        // this just needs to notice when "next fixture" has passed.
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(86_400)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func nextFixture() -> Fixture? {
        let now = Date()
        // fixtures(forTeamID:) is already sorted soonest-first.
        return LeagueData.fixtures(forTeamID: MyTeam.teamID).first { $0.date >= now }
    }
}

struct NextFixtureWidgetView: View {
    var entry: FixtureEntry

    var body: some View {
        Group {
            if let fixture = entry.fixture {
                content(for: fixture)
            } else {
                emptyState
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(colors: [Theme.fortressBlue, Theme.stoneDark], startPoint: .top, endPoint: .bottom)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 22))
            Text("No upcoming fixtures")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(.white.opacity(0.7))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func content(for fixture: Fixture) -> some View {
        let isHome = fixture.isHome(for: MyTeam.teamID)
        let opponentName = LeagueData.team(id: fixture.opponentID(for: MyTeam.teamID))?.name ?? "TBC"

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 11, weight: .semibold))
                Text("NEXT UP")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1)
            }
            .foregroundStyle(.white.opacity(0.6))

            Text("vs \(opponentName)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 2)

            detailRow(icon: "calendar", text: Self.dateFormatter.string(from: fixture.date))
            HStack(spacing: 5) {
                Image(systemName: "clock.fill")
                Text(Self.timeFormatter.string(from: fixture.date))
                Text("·")
                Text(isHome ? "Home" : "Away")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.85))
            detailRow(icon: "mappin.and.ellipse", text: venueText(isHome: isHome, opponentName: opponentName), lineLimit: 1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func detailRow(icon: String, text: String, lineLimit: Int? = nil) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text).lineLimit(lineLimit)
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.white.opacity(0.85))
    }

    private func venueText(isHome: Bool, opponentName: String) -> String {
        if isHome {
            return PitchVenue.venue(id: MyTeam.pitchVenueID).groundName
        } else if let venue = PitchVenue.matchingCuratedVenue(forTeamName: opponentName) {
            return venue.groundName
        } else {
            return "\(opponentName)'s ground"
        }
    }

    private static let dateFormatter: DateFormatter = {
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

struct NextFixtureWidget: Widget {
    let kind = "NextFixtureWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextFixtureProvider()) { entry in
            NextFixtureWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Fixture")
        .description("Shows Barnes M3's next upcoming match.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    NextFixtureWidget()
} timeline: {
    FixtureEntry(date: Date(), fixture: LeagueData.fixtures(forTeamID: MyTeam.teamID).first)
}
