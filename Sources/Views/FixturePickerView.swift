import SwiftUI

/// Prefills a lineup's opposition/date/home-or-away from a real scraped
/// league fixture instead of typing it by hand. Currently seeded with just
/// Barnes M3's division — see `LeagueData`.
struct FixturePickerView: View {
    var onSelect: (Fixture) -> Void

    @Environment(\.dismiss) private var dismiss

    private let myTeamID = MyTeam.teamID
    private var team: HockeyTeam? { LeagueData.team(id: myTeamID) }
    private var fixtures: [Fixture] { LeagueData.fixtures(forTeamID: myTeamID) }

    var body: some View {
        NavigationStack {
            Group {
                if fixtures.isEmpty {
                    ContentUnavailableView(
                        "No Fixtures Yet",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("The fixture database only covers a few rounds so far.")
                    )
                } else {
                    List {
                        Section(team?.divisionName ?? "") {
                            ForEach(fixtures) { fixture in
                                Button {
                                    onSelect(fixture)
                                    dismiss()
                                } label: {
                                    FixtureRow(fixture: fixture, myTeamID: myTeamID)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose a Fixture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct FixtureRow: View {
    var fixture: Fixture
    var myTeamID: String

    private var opponentName: String {
        LeagueData.team(id: fixture.opponentID(for: myTeamID))?.name ?? "Unknown"
    }

    private var isHome: Bool { fixture.isHome(for: myTeamID) }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM yyyy"
        return formatter.string(from: fixture.date)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("vs \(opponentName)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(dateText)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(isHome ? "HOME" : "AWAY")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(isHome ? .green : .orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule())
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    FixturePickerView { _ in }
}
