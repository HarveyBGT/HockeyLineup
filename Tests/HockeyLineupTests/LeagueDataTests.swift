import Testing
@testable import HockeyLineup

struct LeagueDataTests {
    @Test func divisionHasTwelveUniqueTeams() {
        #expect(LeagueData.teams.count == 12)
        #expect(Set(LeagueData.teams.map(\.id)).count == 12)
    }

    /// 12 teams playing a full double round-robin (home + away against every
    /// other team) is 22 rounds of 6 matches — 132 fixtures total.
    @Test func fullSeasonHas132Fixtures() {
        #expect(LeagueData.fixtures.count == 132)
    }

    @Test func fixtureIDsAreUnique() {
        let ids = LeagueData.fixtures.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func everyTeamPlaysExactlyTwentyTwoFixtures() {
        for team in LeagueData.teams {
            let count = LeagueData.fixtures(forTeamID: team.id).count
            #expect(count == 22, "\(team.name) should have 22 fixtures, found \(count)")
        }
    }

    /// Every team should face each of its 11 divisional opponents exactly
    /// once at home and once away.
    @Test func everyTeamPlaysEachOpponentHomeAndAway() {
        for team in LeagueData.teams {
            let fixtures = LeagueData.fixtures(forTeamID: team.id)
            var homeCounts: [String: Int] = [:]
            var awayCounts: [String: Int] = [:]
            for fixture in fixtures {
                guard let opponent = fixture.opponentID(for: team.id) else { continue }
                if fixture.isHome(for: team.id) {
                    homeCounts[opponent, default: 0] += 1
                } else {
                    awayCounts[opponent, default: 0] += 1
                }
            }
            let otherTeamIDs = LeagueData.teams.map(\.id).filter { $0 != team.id }
            for opponentID in otherTeamIDs {
                #expect(homeCounts[opponentID] == 1, "\(team.name) should host \(opponentID) exactly once")
                #expect(awayCounts[opponentID] == 1, "\(team.name) should visit \(opponentID) exactly once")
            }
        }
    }

    @Test func fixturesAreSortedChronologicallyPerTeam() {
        let fixtures = LeagueData.fixtures(forTeamID: MyTeam.teamID)
        let dates = fixtures.map(\.date)
        #expect(dates == dates.sorted())
    }

    @Test func myTeamResolvesToBarnesM3() {
        #expect(MyTeam.name == "Barnes M3")
        #expect(LeagueData.team(id: MyTeam.teamID)?.name == "Barnes M3")
    }

    @Test func unknownTeamIDLookupReturnsNil() {
        #expect(LeagueData.team(id: "not-a-real-team") == nil)
        #expect(LeagueData.team(id: nil) == nil)
    }
}
