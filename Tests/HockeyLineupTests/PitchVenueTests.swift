import Testing
@testable import HockeyLineup

struct PitchVenueTests {
    @Test func unknownVenueIDFallsBackToClassicGreen() {
        let venue = PitchVenue.venue(id: "not-a-real-venue")
        #expect(venue.id == PitchVenue.classicGreen.id)
    }

    @Test func nilVenueIDFallsBackToClassicGreen() {
        let venue = PitchVenue.venue(id: nil)
        #expect(venue.id == PitchVenue.classicGreen.id)
    }

    @Test func catalogEntriesHaveUniqueIDs() {
        let ids = PitchVenue.catalog.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func barnesCrestUsesBridgeMotif() {
        let barnes = PitchVenue.venue(id: "barnes")
        #expect(barnes.crest.motif == .bridge)
    }

    @Test func crestForKnownClubNameMatchesCuratedCrest() {
        let crest = ClubCrest.forTeamName("Teddington HC")
        #expect(crest.motif == .tree)
    }

    @Test func crestForUnknownTeamNameSynthesizesAMonogram() {
        let crest = ClubCrest.forTeamName("Some Made Up Hockey Club")
        #expect(crest.motif == .monogram)
        #expect(!crest.initials.isEmpty)
    }

    @Test func crestSynthesisIsDeterministic() {
        let first = ClubCrest.forTeamName("Repeatable Rangers")
        let second = ClubCrest.forTeamName("Repeatable Rangers")
        #expect(first == second)
    }

    @Test func allBarnesM3DivisionOpponentsAreCurated() {
        // Every opponent in LeagueData's division should now resolve to a
        // real venue, not just Barnes' own club, so away fixtures always
        // show a real ground.
        let opponents = LeagueData.teams.map(\.name).filter { $0 != MyTeam.name }
        for opponent in opponents {
            #expect(PitchVenue.matchingCuratedVenue(forTeamName: opponent) != nil, "\(opponent) should have a curated venue")
        }
    }

    @Test func matchingCuratedVenueReturnsNilForUnknownClub() {
        #expect(PitchVenue.matchingCuratedVenue(forTeamName: "Some Made Up Club") == nil)
    }

    @Test func matchingCuratedVenueReturnsNilForEmptyName() {
        #expect(PitchVenue.matchingCuratedVenue(forTeamName: "") == nil)
    }
}
