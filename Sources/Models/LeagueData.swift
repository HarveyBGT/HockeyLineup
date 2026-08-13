import Foundation

struct HockeyTeam: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var divisionName: String
}

struct Fixture: Identifiable, Codable, Hashable {
    var id: String
    var divisionName: String
    var date: Date
    var homeTeamID: String
    var awayTeamID: String

    func opponentID(for teamID: String) -> String? {
        if homeTeamID == teamID { return awayTeamID }
        if awayTeamID == teamID { return homeTeamID }
        return nil
    }

    func isHome(for teamID: String) -> Bool {
        homeTeamID == teamID
    }
}

/// Seed data pulled live from london.englandhockey.co.uk (London Open -
/// Men's Division 3 South, 2026-2027 season): the full 12-team division and
/// its complete 22-round double round-robin fixture list (each team plays
/// every other team home and away). No public API exists for this data — it's
/// server-rendered client-side — so this was scraped with a real browser and
/// is a point-in-time snapshot, not a live feed. Structured so more divisions
/// can be appended without changing the model.
enum LeagueData {
    static let division3South = "London Open - Men's Division 3 South"

    static let teams: [HockeyTeam] = [
        HockeyTeam(id: "barnes-m3", name: "Barnes M3", divisionName: division3South),
        HockeyTeam(id: "old-tonbridgians-m1", name: "Old Tonbridgians M1", divisionName: division3South),
        HockeyTeam(id: "london-gamblers-m1", name: "London Gamblers M1", divisionName: division3South),
        HockeyTeam(id: "cheam-m1", name: "Cheam M1", divisionName: division3South),
        HockeyTeam(id: "purley-walcountians-m2", name: "Purley Walcountians M2", divisionName: division3South),
        HockeyTeam(id: "bromley-beckenham-m3", name: "Bromley & Beckenham M3", divisionName: division3South),
        HockeyTeam(id: "spencer-m6", name: "Spencer M6", divisionName: division3South),
        HockeyTeam(id: "spencer-m5", name: "Spencer M5", divisionName: division3South),
        HockeyTeam(id: "tulse-hill-dulwich-m3", name: "Tulse Hill & Dulwich M3", divisionName: division3South),
        HockeyTeam(id: "wanderers-m3", name: "Wanderers M3", divisionName: division3South),
        HockeyTeam(id: "wimbledon-m4", name: "Wimbledon M4", divisionName: division3South),
        HockeyTeam(id: "london-wayfarers-outlaws", name: "London Wayfarers Outlaws", divisionName: division3South),
    ]

    static let fixtures: [Fixture] = [
        // Round 1 — Sat 19 Sep 2026
        fx(2026, 9, 19, "barnes-m3", "old-tonbridgians-m1"),
        fx(2026, 9, 19, "london-gamblers-m1", "cheam-m1"),
        fx(2026, 9, 19, "purley-walcountians-m2", "bromley-beckenham-m3"),
        fx(2026, 9, 19, "spencer-m6", "spencer-m5"),
        fx(2026, 9, 19, "tulse-hill-dulwich-m3", "wanderers-m3"),
        fx(2026, 9, 19, "wimbledon-m4", "london-wayfarers-outlaws"),

        // Round 2 — Sat 26 Sep 2026
        fx(2026, 9, 26, "bromley-beckenham-m3", "london-gamblers-m1"),
        fx(2026, 9, 26, "cheam-m1", "spencer-m6"),
        fx(2026, 9, 26, "london-wayfarers-outlaws", "purley-walcountians-m2"),
        fx(2026, 9, 26, "old-tonbridgians-m1", "wimbledon-m4"),
        fx(2026, 9, 26, "wanderers-m3", "barnes-m3"),
        fx(2026, 9, 26, "spencer-m5", "tulse-hill-dulwich-m3"),

        // Round 3 — Sat 3 Oct 2026
        fx(2026, 10, 3, "barnes-m3", "spencer-m5"),
        fx(2026, 10, 3, "london-gamblers-m1", "london-wayfarers-outlaws"),
        fx(2026, 10, 3, "old-tonbridgians-m1", "wanderers-m3"),
        fx(2026, 10, 3, "spencer-m6", "bromley-beckenham-m3"),
        fx(2026, 10, 3, "wimbledon-m4", "purley-walcountians-m2"),
        fx(2026, 10, 3, "tulse-hill-dulwich-m3", "cheam-m1"),

        // Round 4 — Sat 10 Oct 2026
        fx(2026, 10, 10, "bromley-beckenham-m3", "tulse-hill-dulwich-m3"),
        fx(2026, 10, 10, "cheam-m1", "barnes-m3"),
        fx(2026, 10, 10, "london-wayfarers-outlaws", "spencer-m6"),
        fx(2026, 10, 10, "spencer-m5", "old-tonbridgians-m1"),
        fx(2026, 10, 10, "purley-walcountians-m2", "london-gamblers-m1"),
        fx(2026, 10, 10, "wanderers-m3", "wimbledon-m4"),

        // Round 5 — Sat 17 Oct 2026
        fx(2026, 10, 17, "wimbledon-m4", "london-gamblers-m1"),
        fx(2026, 10, 17, "barnes-m3", "bromley-beckenham-m3"),
        fx(2026, 10, 17, "wanderers-m3", "spencer-m5"),
        fx(2026, 10, 17, "tulse-hill-dulwich-m3", "london-wayfarers-outlaws"),
        fx(2026, 10, 17, "old-tonbridgians-m1", "cheam-m1"),
        fx(2026, 10, 17, "spencer-m6", "purley-walcountians-m2"),

        // Round 6 — Sat 31 Oct 2026
        fx(2026, 10, 31, "bromley-beckenham-m3", "old-tonbridgians-m1"),
        fx(2026, 10, 31, "london-gamblers-m1", "spencer-m6"),
        fx(2026, 10, 31, "cheam-m1", "wanderers-m3"),
        fx(2026, 10, 31, "london-wayfarers-outlaws", "barnes-m3"),
        fx(2026, 10, 31, "purley-walcountians-m2", "tulse-hill-dulwich-m3"),
        fx(2026, 10, 31, "spencer-m5", "wimbledon-m4"),

        // Round 7 — Sat 7 Nov 2026
        fx(2026, 11, 7, "barnes-m3", "purley-walcountians-m2"),
        fx(2026, 11, 7, "old-tonbridgians-m1", "london-wayfarers-outlaws"),
        fx(2026, 11, 7, "spencer-m5", "cheam-m1"),
        fx(2026, 11, 7, "tulse-hill-dulwich-m3", "london-gamblers-m1"),
        fx(2026, 11, 7, "wanderers-m3", "bromley-beckenham-m3"),
        fx(2026, 11, 7, "wimbledon-m4", "spencer-m6"),

        // Round 8 — Sat 14 Nov 2026
        fx(2026, 11, 14, "bromley-beckenham-m3", "spencer-m5"),
        fx(2026, 11, 14, "cheam-m1", "wimbledon-m4"),
        fx(2026, 11, 14, "london-gamblers-m1", "barnes-m3"),
        fx(2026, 11, 14, "purley-walcountians-m2", "old-tonbridgians-m1"),
        fx(2026, 11, 14, "london-wayfarers-outlaws", "wanderers-m3"),
        fx(2026, 11, 14, "spencer-m6", "tulse-hill-dulwich-m3"),

        // Round 9 — Sat 21 Nov 2026
        fx(2026, 11, 21, "barnes-m3", "spencer-m6"),
        fx(2026, 11, 21, "cheam-m1", "bromley-beckenham-m3"),
        fx(2026, 11, 21, "old-tonbridgians-m1", "london-gamblers-m1"),
        fx(2026, 11, 21, "spencer-m5", "london-wayfarers-outlaws"),
        fx(2026, 11, 21, "tulse-hill-dulwich-m3", "wimbledon-m4"),
        fx(2026, 11, 21, "wanderers-m3", "purley-walcountians-m2"),

        // Round 10 — Sat 28 Nov 2026
        fx(2026, 11, 28, "london-gamblers-m1", "wanderers-m3"),
        fx(2026, 11, 28, "london-wayfarers-outlaws", "cheam-m1"),
        fx(2026, 11, 28, "purley-walcountians-m2", "spencer-m5"),
        fx(2026, 11, 28, "tulse-hill-dulwich-m3", "barnes-m3"),
        fx(2026, 11, 28, "spencer-m6", "old-tonbridgians-m1"),
        fx(2026, 11, 28, "wimbledon-m4", "bromley-beckenham-m3"),

        // Round 11 — Sat 5 Dec 2026
        fx(2026, 12, 5, "spencer-m5", "london-gamblers-m1"),
        fx(2026, 12, 5, "wanderers-m3", "spencer-m6"),
        fx(2026, 12, 5, "barnes-m3", "wimbledon-m4"),
        fx(2026, 12, 5, "bromley-beckenham-m3", "london-wayfarers-outlaws"),
        fx(2026, 12, 5, "cheam-m1", "purley-walcountians-m2"),
        fx(2026, 12, 5, "old-tonbridgians-m1", "tulse-hill-dulwich-m3"),

        // Round 12 — Sat 16 Jan 2027
        fx(2027, 1, 16, "bromley-beckenham-m3", "purley-walcountians-m2"),
        fx(2027, 1, 16, "spencer-m5", "spencer-m6"),
        fx(2027, 1, 16, "wanderers-m3", "tulse-hill-dulwich-m3"),
        fx(2027, 1, 16, "london-wayfarers-outlaws", "wimbledon-m4"),
        fx(2027, 1, 16, "old-tonbridgians-m1", "barnes-m3"),
        fx(2027, 1, 16, "cheam-m1", "london-gamblers-m1"),

        // Round 13 — Sat 23 Jan 2027
        fx(2027, 1, 23, "barnes-m3", "wanderers-m3"),
        fx(2027, 1, 23, "purley-walcountians-m2", "london-wayfarers-outlaws"),
        fx(2027, 1, 23, "london-gamblers-m1", "bromley-beckenham-m3"),
        fx(2027, 1, 23, "spencer-m6", "cheam-m1"),
        fx(2027, 1, 23, "tulse-hill-dulwich-m3", "spencer-m5"),
        fx(2027, 1, 23, "wimbledon-m4", "old-tonbridgians-m1"),

        // Round 14 — Sat 30 Jan 2027
        fx(2027, 1, 30, "london-wayfarers-outlaws", "london-gamblers-m1"),
        fx(2027, 1, 30, "purley-walcountians-m2", "wimbledon-m4"),
        fx(2027, 1, 30, "bromley-beckenham-m3", "spencer-m6"),
        fx(2027, 1, 30, "cheam-m1", "tulse-hill-dulwich-m3"),
        fx(2027, 1, 30, "spencer-m5", "barnes-m3"),
        fx(2027, 1, 30, "wanderers-m3", "old-tonbridgians-m1"),

        // Round 15 — Sat 6 Feb 2027
        fx(2027, 2, 6, "old-tonbridgians-m1", "spencer-m5"),
        fx(2027, 2, 6, "barnes-m3", "cheam-m1"),
        fx(2027, 2, 6, "london-gamblers-m1", "purley-walcountians-m2"),
        fx(2027, 2, 6, "spencer-m6", "london-wayfarers-outlaws"),
        fx(2027, 2, 6, "tulse-hill-dulwich-m3", "bromley-beckenham-m3"),
        fx(2027, 2, 6, "wimbledon-m4", "wanderers-m3"),

        // Round 16 — Sat 20 Feb 2027
        fx(2027, 2, 20, "bromley-beckenham-m3", "barnes-m3"),
        fx(2027, 2, 20, "cheam-m1", "old-tonbridgians-m1"),
        fx(2027, 2, 20, "london-gamblers-m1", "wimbledon-m4"),
        fx(2027, 2, 20, "london-wayfarers-outlaws", "tulse-hill-dulwich-m3"),
        fx(2027, 2, 20, "purley-walcountians-m2", "spencer-m6"),
        fx(2027, 2, 20, "spencer-m5", "wanderers-m3"),

        // Round 17 — Sat 27 Feb 2027
        fx(2027, 2, 27, "tulse-hill-dulwich-m3", "purley-walcountians-m2"),
        fx(2027, 2, 27, "barnes-m3", "london-wayfarers-outlaws"),
        fx(2027, 2, 27, "wanderers-m3", "cheam-m1"),
        fx(2027, 2, 27, "old-tonbridgians-m1", "bromley-beckenham-m3"),
        fx(2027, 2, 27, "spencer-m6", "london-gamblers-m1"),
        fx(2027, 2, 27, "wimbledon-m4", "spencer-m5"),

        // Round 18 — Sat 6 Mar 2027
        fx(2027, 3, 6, "bromley-beckenham-m3", "wanderers-m3"),
        fx(2027, 3, 6, "london-gamblers-m1", "tulse-hill-dulwich-m3"),
        fx(2027, 3, 6, "cheam-m1", "spencer-m5"),
        fx(2027, 3, 6, "purley-walcountians-m2", "barnes-m3"),
        fx(2027, 3, 6, "london-wayfarers-outlaws", "old-tonbridgians-m1"),
        fx(2027, 3, 6, "spencer-m6", "wimbledon-m4"),

        // Round 19 — Sat 13 Mar 2027
        fx(2027, 3, 13, "barnes-m3", "london-gamblers-m1"),
        fx(2027, 3, 13, "old-tonbridgians-m1", "purley-walcountians-m2"),
        fx(2027, 3, 13, "spencer-m5", "bromley-beckenham-m3"),
        fx(2027, 3, 13, "tulse-hill-dulwich-m3", "spencer-m6"),
        fx(2027, 3, 13, "wanderers-m3", "london-wayfarers-outlaws"),
        fx(2027, 3, 13, "wimbledon-m4", "cheam-m1"),

        // Round 20 — Sat 20 Mar 2027
        fx(2027, 3, 20, "london-gamblers-m1", "old-tonbridgians-m1"),
        fx(2027, 3, 20, "london-wayfarers-outlaws", "spencer-m5"),
        fx(2027, 3, 20, "purley-walcountians-m2", "wanderers-m3"),
        fx(2027, 3, 20, "spencer-m6", "barnes-m3"),
        fx(2027, 3, 20, "wimbledon-m4", "tulse-hill-dulwich-m3"),
        fx(2027, 3, 20, "bromley-beckenham-m3", "cheam-m1"),

        // Round 21 — Sat 10 Apr 2027
        fx(2027, 4, 10, "barnes-m3", "tulse-hill-dulwich-m3"),
        fx(2027, 4, 10, "bromley-beckenham-m3", "wimbledon-m4"),
        fx(2027, 4, 10, "cheam-m1", "london-wayfarers-outlaws"),
        fx(2027, 4, 10, "old-tonbridgians-m1", "spencer-m6"),
        fx(2027, 4, 10, "wanderers-m3", "london-gamblers-m1"),
        fx(2027, 4, 10, "spencer-m5", "purley-walcountians-m2"),

        // Round 22 — Sat 17 Apr 2027
        fx(2027, 4, 17, "london-gamblers-m1", "spencer-m5"),
        fx(2027, 4, 17, "london-wayfarers-outlaws", "bromley-beckenham-m3"),
        fx(2027, 4, 17, "purley-walcountians-m2", "cheam-m1"),
        fx(2027, 4, 17, "spencer-m6", "wanderers-m3"),
        fx(2027, 4, 17, "tulse-hill-dulwich-m3", "old-tonbridgians-m1"),
        fx(2027, 4, 17, "wimbledon-m4", "barnes-m3"),
    ]

    static func team(id: String?) -> HockeyTeam? {
        guard let id else { return nil }
        return teams.first { $0.id == id }
    }

    static func fixture(id: String?) -> Fixture? {
        guard let id else { return nil }
        return fixtures.first { $0.id == id }
    }

    /// Fixtures involving the given team, soonest first.
    static func fixtures(forTeamID teamID: String) -> [Fixture] {
        fixtures.filter { $0.homeTeamID == teamID || $0.awayTeamID == teamID }.sorted { $0.date < $1.date }
    }

    private static func fx(_ year: Int, _ month: Int, _ day: Int, _ homeTeamID: String, _ awayTeamID: String) -> Fixture {
        let matchDate = date(year, month, day)
        let id = "d3s-\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))-\(homeTeamID)-\(awayTeamID)"
        return Fixture(id: id, divisionName: division3South, date: matchDate, homeTeamID: homeTeamID, awayTeamID: awayTeamID)
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}

/// The one team this app currently builds lineups for. Backed by
/// `UserDefaults` (via `ClubSettingsView`) rather than hardcoded, so any team
/// already in `LeagueData.teams` can be picked as "my team" without a
/// rebuild — defaults to Barnes M3 / Dukes Meadow if never changed.
///
/// Note: this only reconfigures the main app (lineup building, export,
/// Season Record). The widget and Watch targets read their own sandboxed
/// `UserDefaults` and can't see this change without an App Group — the same
/// class of one-time manual setup already required for iCloud sync (see
/// README). They'll keep showing whatever team they were last built with.
enum MyTeam {
    private static let teamIDDefaultsKey = "MyTeam.teamID"
    private static let pitchVenueIDDefaultsKey = "MyTeam.pitchVenueID"

    static var teamID: String {
        get { UserDefaults.standard.string(forKey: teamIDDefaultsKey) ?? "barnes-m3" }
        set { UserDefaults.standard.set(newValue, forKey: teamIDDefaultsKey) }
    }

    static var pitchVenueID: String? {
        get { UserDefaults.standard.string(forKey: pitchVenueIDDefaultsKey) ?? "barnes" }
        set { UserDefaults.standard.set(newValue, forKey: pitchVenueIDDefaultsKey) }
    }

    static var name: String { LeagueData.team(id: teamID)?.name ?? "My Team" }
}
