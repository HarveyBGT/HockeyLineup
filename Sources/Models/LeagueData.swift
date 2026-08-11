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
/// Men's Division 3 South, 2026-2027 season). Currently just Barnes M3's
/// division and the first few rounds of their fixtures — the rest of the
/// league (other divisions, later rounds) hasn't been pulled in yet, but
/// this is deliberately structured so more teams/fixtures can be appended
/// without changing the model.
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
        Fixture(id: "d3s-2026-09-19-barnes-tonbridgians", divisionName: division3South, date: date(2026, 9, 19), homeTeamID: "barnes-m3", awayTeamID: "old-tonbridgians-m1"),
        Fixture(id: "d3s-2026-09-26-wanderers-barnes", divisionName: division3South, date: date(2026, 9, 26), homeTeamID: "wanderers-m3", awayTeamID: "barnes-m3"),
        Fixture(id: "d3s-2026-10-03-barnes-spencerm5", divisionName: division3South, date: date(2026, 10, 3), homeTeamID: "barnes-m3", awayTeamID: "spencer-m5"),
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

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}

/// The one team this app currently builds lineups for. Hardcoded for now —
/// generalize this (e.g. a settings screen to pick "my team" from
/// `LeagueData.teams`) once more of the league is pulled in.
enum MyTeam {
    static let teamID = "barnes-m3"
    static let pitchVenueID = "barnes"
    static var name: String { LeagueData.team(id: teamID)?.name ?? "My Team" }
}
