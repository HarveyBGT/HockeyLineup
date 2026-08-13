import Foundation

/// Aggregate squad stats shown on the Squad screen's header — pulled out of
/// the view so the counting logic is testable on its own, same pattern as
/// `SeasonRecord`.
struct SquadSummary: Equatable {
    var total: Int
    var goalkeepers: Int
    var withPreferredRole: Int
}

extension Array where Element == Player {
    var squadSummary: SquadSummary {
        SquadSummary(
            total: count,
            goalkeepers: filter { $0.isGoalkeeper }.count,
            withPreferredRole: filter { $0.preferredRole != nil }.count
        )
    }
}
