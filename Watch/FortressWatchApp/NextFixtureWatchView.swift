import SwiftUI

/// The watch app's only screen: Barnes M3's next fixture, at a glance.
/// Deliberately self-contained — reads only the static `LeagueData`/
/// `PitchVenue` seed data (no shared container, no `Theme`/`Color+Hex`,
/// since those pull in UIKit which doesn't exist on watchOS) so the app
/// works standalone with no extra setup.
struct NextFixtureWatchView: View {
    private var fixture: Fixture? {
        LeagueData.fixtures(forTeamID: MyTeam.teamID).first { $0.date >= Date() }
    }

    var body: some View {
        ScrollView {
            if let fixture {
                content(for: fixture)
            } else {
                emptyState
            }
        }
        .navigationTitle("Fortress")
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 28))
            Text("No upcoming fixtures")
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(.secondary)
        .padding(.top, 40)
    }

    private func content(for fixture: Fixture) -> some View {
        let isHome = fixture.isHome(for: MyTeam.teamID)
        let opponentName = LeagueData.team(id: fixture.opponentID(for: MyTeam.teamID))?.name ?? "TBC"

        return VStack(alignment: .leading, spacing: 8) {
            Text("NEXT UP")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1)
                .foregroundStyle(.secondary)

            Text("vs \(opponentName)")
                .font(.system(size: 17, weight: .bold, design: .rounded))

            row(icon: "calendar", text: Self.dateFormatter.string(from: fixture.date))
            row(icon: "clock.fill", text: "\(Self.timeFormatter.string(from: fixture.date)) · \(isHome ? "Home" : "Away")")
            row(icon: "mappin.and.ellipse", text: venueText(isHome: isHome, opponentName: opponentName))
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
    }

    private func row(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(.secondary)
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

#Preview {
    NextFixtureWatchView()
}
