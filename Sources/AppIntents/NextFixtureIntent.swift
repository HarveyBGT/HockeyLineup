import AppIntents
import Foundation

/// Answers "what's the next fixture" via Siri or Shortcuts, straight from
/// the static `LeagueData` seed — same read-only data source as the widget,
/// so no app UI needs to open and no lineup state can be touched by voice.
struct NextFixtureIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Fixture"
    static var description = IntentDescription("Hear Barnes M3's next upcoming hockey fixture.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let fixture = LeagueData.fixtures(forTeamID: MyTeam.teamID).first(where: { $0.date >= Date() }) else {
            return .result(dialog: "There's no upcoming fixture scheduled.")
        }

        let opponentName = LeagueData.team(id: fixture.opponentID(for: MyTeam.teamID))?.name ?? "TBC"
        let isHome = fixture.isHome(for: MyTeam.teamID)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM 'at' HH:mm"
        let dateText = dateFormatter.string(from: fixture.date)

        let venue: String
        if isHome {
            venue = PitchVenue.venue(id: MyTeam.pitchVenueID).groundName
        } else if let curated = PitchVenue.matchingCuratedVenue(forTeamName: opponentName) {
            venue = curated.groundName
        } else {
            venue = "\(opponentName)'s ground"
        }

        let homeAway = isHome ? "at home" : "away"
        let dialog = "\(MyTeam.name) play \(opponentName) \(homeAway) on \(dateText), at \(venue)."
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}

/// Registers `NextFixtureIntent` as a Siri Shortcut / Spotlight suggestion
/// out of the box — no manual "Add to Siri" step required.
struct FortressShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NextFixtureIntent(),
            phrases: [
                "When's the next \(.applicationName) fixture",
                "What's the next \(.applicationName) match",
                "Who does \(.applicationName) play next"
            ],
            shortTitle: "Next Fixture",
            systemImageName: "sportscourt"
        )
    }
}
