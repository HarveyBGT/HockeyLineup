import SwiftUI

/// Prefills a lineup's opposition/date/home-or-away from a real scraped
/// league fixture instead of typing it by hand. Seeded with Barnes M3's full
/// 22-round 2026-2027 season — see `LeagueData`.
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
                        description: Text("No known fixtures for this team yet.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(fixtures) { fixture in
                                Button {
                                    onSelect(fixture)
                                    dismiss()
                                } label: {
                                    FixtureRow(fixture: fixture, myTeamID: myTeamID)
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            Text(team?.divisionName ?? "")
                        } footer: {
                            Text("This is a point-in-time snapshot of the published fixture list, not a live feed — if a match is postponed or rescheduled, pick it here as normal and then edit the date on the lineup itself.")
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
                .foregroundStyle(isHome ? Theme.fortressBlue : Theme.fortressGold)
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
