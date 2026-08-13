import Foundation

/// Aggregate win/draw/loss counts across a set of lineups — shared by
/// `SeasonRecordView` and the home screen's hero card so the counting logic
/// only lives in one, testable place.
struct SeasonRecord: Equatable {
    var wins: Int
    var draws: Int
    var losses: Int

    var played: Int { wins + draws + losses }
}

extension Array where Element == LineupCard {
    var seasonRecord: SeasonRecord {
        let played = filter { $0.result != nil }
        return SeasonRecord(
            wins: played.filter { $0.result == .win }.count,
            draws: played.filter { $0.result == .draw }.count,
            losses: played.filter { $0.result == .loss }.count
        )
    }
}
