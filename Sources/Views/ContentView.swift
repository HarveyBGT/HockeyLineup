import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LineupStore
    @State private var showFormationPicker = false
    @State private var showPlayerDatabase = false
    @State private var showSeasonRecord = false
    @State private var showClubSettings = false
    @State private var selectedCardID: UUID?

    private var sortedCards: [LineupCard] {
        store.cards.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    /// The next fixture on the calendar for whichever team Club Settings has
    /// configured — shown in the hero card so the home screen means
    /// something even before a single lineup's been built.
    private var nextFixture: Fixture? {
        let now = Date()
        return LeagueData.fixtures(forTeamID: MyTeam.teamID).first { $0.date >= now }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroCard
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    if store.cards.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(sortedCards) { card in
                                Button {
                                    selectedCardID = card.id
                                } label: {
                                    LineupRow(card: card)
                                }
                                .buttonStyle(PressableCardStyle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.delete(id: card.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Fortress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showPlayerDatabase = true
                    } label: {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 18))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSeasonRecord = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 18))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showClubSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFormationPicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showPlayerDatabase) {
                PlayerDatabaseView()
            }
            .sheet(isPresented: $showSeasonRecord) {
                SeasonRecordView()
            }
            .sheet(isPresented: $showClubSettings) {
                ClubSettingsView()
            }
            .sheet(isPresented: $showFormationPicker) {
                FormationPickerView { formation in
                    let card = LineupCard(formation: formation)
                    store.upsert(card)
                    showFormationPicker = false
                    selectedCardID = card.id
                }
            }
            .navigationDestination(item: $selectedCardID) { id in
                LineupEditorView(cardID: id)
            }
        }
    }

    /// The club identity + next-fixture teaser — the one moment on this
    /// screen worth real colour and depth, same hero-gradient language as
    /// the pitch panel in the editor.
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                ClubCrestView(crest: PitchVenue.venue(id: MyTeam.pitchVenueID).crest, size: 40)
                    .padding(8)
                    .glassCircle()

                VStack(alignment: .leading, spacing: 2) {
                    Text(MyTeam.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(PitchVenue.venue(id: MyTeam.pitchVenueID).groundName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.fortressGold.opacity(0.5))
            }

            if let nextFixture {
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 1)

                nextFixtureRow(nextFixture)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge + 4, style: .continuous)
                .fill(Theme.heroGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge + 4, style: .continuous)
                .stroke(Theme.fortressGold.opacity(0.3), lineWidth: 1)
        )
        .elevatedShadow()
    }

    private func nextFixtureRow(_ fixture: Fixture) -> some View {
        let opponentName = LeagueData.team(id: fixture.opponentID(for: MyTeam.teamID))?.name ?? "TBC"
        let isHome = fixture.isHome(for: MyTeam.teamID)

        return VStack(alignment: .leading, spacing: 6) {
            Text("NEXT UP")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(Theme.fortressGold)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("vs \(opponentName)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(Self.heroDateFormatter.string(from: fixture.date)) · \(isHome ? "Home" : "Away")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 40))
                .foregroundStyle(Theme.fortressBlue)
            Text("No Lineups Yet")
                .font(.system(size: 19, weight: .bold, design: .rounded))
            Text("Tap + to build your first Fortress XI.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("New Lineup") { showFormationPicker = true }
                .modifier(ProminentGlassButtonModifier())
                .tint(Theme.fortressBlue)
        }
        .padding(.horizontal, 32)
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }

    private static let heroDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM 'at' HH:mm"
        return formatter
    }()
}

private struct LineupRow: View {
    var card: LineupCard

    private var color: Color { Color(hex: card.activeColorHex) }

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.accentGradient(color))
                .frame(width: 52, height: 52)
                .overlay(
                    Text(card.formation.name)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                )
                .shadow(color: color.opacity(0.35), radius: 6, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 3) {
                Text(card.clubName.isEmpty ? "Untitled Lineup" : card.clubName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                if !card.matchSummaryText.isEmpty {
                    Text(card.matchSummaryText)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()

            if let result = card.result, let scoreText = card.scoreText {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(result.label.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(0.5)
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Theme.resultColor(result), in: Capsule())
                    Text(scoreText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .tintedGlassCard(tint: color)
        .elevatedShadow()
        .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous))
    }
}

#Preview {
    ContentView()
        .environmentObject(LineupStore())
}
