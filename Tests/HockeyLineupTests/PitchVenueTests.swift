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
}
