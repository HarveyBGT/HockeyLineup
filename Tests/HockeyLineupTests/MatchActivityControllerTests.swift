import Testing
@testable import HockeyLineup

/// Only the pure parts of `MatchActivityController` are covered here — the
/// actual ActivityKit start/update/end calls need a real Live Activity
/// subsystem and aren't something a unit test should exercise.
struct MatchActivityControllerTests {
    @Test func clampedNeverGoesNegative() {
        #expect(MatchActivityController.clamped(-5) == 0)
        #expect(MatchActivityController.clamped(-1) == 0)
        #expect(MatchActivityController.clamped(0) == 0)
    }

    @Test func clampedLeavesNonNegativeValuesUnchanged() {
        #expect(MatchActivityController.clamped(1) == 1)
        #expect(MatchActivityController.clamped(42) == 42)
    }

    @Test func statusOptionsStartsAtKickoffAndEndsAtFullTime() {
        #expect(MatchActivityController.statusOptions.first == "Kickoff")
        #expect(MatchActivityController.statusOptions.last == "Full Time")
    }
}
