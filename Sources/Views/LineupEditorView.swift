import SwiftUI

struct LineupEditorView: View {
    let cardID: UUID

    @EnvironmentObject private var store: LineupStore
    @EnvironmentObject private var playerStore: PlayerStore
    @Environment(\.dismiss) private var dismiss

    @State private var card: LineupCard = LineupCard(formation: Formation.presets[0])
    @State private var homeColor: Color = .init(hex: "#1C63A8")
    @State private var awayColor: Color = .init(hex: "#FFFFFF")
    @State private var showPitchPicker = false
    @State private var showFixturePicker = false
    @State private var editingBenchIndex: Int?
    @State private var benchDragTargetIndex: Int?
    @State private var loaded = false
    @State private var calendarAlertMessage: String?
    @State private var showCalendarAlert = false
    @StateObject private var liveActivity = MatchActivityController()

    /// The kit colour actually in effect right now, given home/away.
    private var color: Color { card.isHome ? homeColor : awayColor }

    /// The pitch and its two primary actions, framed in a hero panel — the
    /// one place in the screen worth giving real colour and depth to, since
    /// Liquid Glass needs something richer than flat system grey to
    /// actually refract and throw specular highlights.
    private var heroPanel: some View {
        VStack(spacing: 14) {
            PitchView(
                formation: card.formation,
                playerIDs: $card.playerIDs,
                playerStore: playerStore,
                accentColor: color,
                pitchColor: Color(hex: card.pitchVenue.colorHex),
                slotLabel: { index, playerID in card.placementLabel(for: playerID, excluding: .pitch(index)) },
                onAssign: { index, newID in card.assign(newID, to: .pitch(index)) },
                onSwap: { source, destination in card.swapOrMove(from: source, to: destination) }
            )
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge, style: .continuous))
                .elevatedShadow()

            actionButtonsRow
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge + 8, style: .continuous)
                .fill(Theme.heroGradient)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var actionButtonsRow: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 10) {
                actionButtons
            }
        } else {
            actionButtons
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button {
                showFixturePicker = true
            } label: {
                Label("Use a Fixture", systemImage: "calendar.badge.checkmark")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .modifier(ProminentGlassButtonModifier())

            Button {
                LineupAutoFiller.fill(&card, from: playerStore.players)
            } label: {
                Label("Auto-Fill", systemImage: "wand.and.stars")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .modifier(ProminentGlassButtonModifier())
            .tint(Theme.fortressGold)
            .disabled(LineupAutoFiller.unassignedSquad(playerStore.players, notIn: card).isEmpty)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                heroPanel

                MatchDetailsSection(card: $card, accentColor: color, onAddToCalendar: addToCalendar)
                ResultSection(card: $card)
                MatchDaySection(card: $card, activity: liveActivity)
                KitFormationSection(card: $card, homeColor: $homeColor, awayColor: $awayColor) {
                    showPitchPicker = true
                }
                SuperSubsSection(
                    card: $card,
                    playerStore: playerStore,
                    accentColor: color,
                    benchDragTargetIndex: $benchDragTargetIndex,
                    onEditBenchIndex: { editingBenchIndex = $0 }
                )

                Button {
                    exportAndShare()
                } label: {
                    Label("Share Lineup", systemImage: "square.and.arrow.up.fill")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .modifier(ProminentGlassButtonModifier())
                .tint(color)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Edit Lineup")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !loaded else { return }
            if let existing = store.card(id: cardID) {
                card = existing
                homeColor = Color(hex: existing.homeColorHex)
                awayColor = Color(hex: existing.awayColorHex)
            } else {
                card.id = cardID
            }
            loaded = true
            liveActivity.reattach(opponentName: card.opposition)
        }
        .onChange(of: card) { _, newValue in
            store.upsert(newValue)
        }
        .onChange(of: homeColor) { _, newValue in
            card.homeColorHex = newValue.hexString
        }
        .onChange(of: awayColor) { _, newValue in
            card.awayColorHex = newValue.hexString
        }
        .sheet(isPresented: $showPitchPicker) {
            PitchVenuePickerView(selectedID: card.pitchVenueID) { venue in
                card.pitchVenueID = venue.id
                showPitchPicker = false
            }
        }
        .sheet(isPresented: $showFixturePicker) {
            FixturePickerView { fixture in
                card.clubName = MyTeam.name
                card.opposition = LeagueData.team(id: fixture.opponentID(for: MyTeam.teamID))?.name ?? card.opposition
                card.matchDate = fixture.date
                card.isHome = fixture.isHome(for: MyTeam.teamID)
                card.linkedFixtureID = fixture.id
                // Away fixtures clear the venue rather than leaving Barnes'
                // own ground set — we don't have real pitch data for most
                // opponents yet, so `venueText` falls back to naming them
                // instead of showing the wrong specific ground.
                card.pitchVenueID = card.isHome ? MyTeam.pitchVenueID : nil
            }
        }
        .sheet(isPresented: Binding(
            get: { editingBenchIndex != nil },
            set: { if !$0 { editingBenchIndex = nil } }
        )) {
            if let index = editingBenchIndex {
                PlayerPickerView(
                    positionRole: .midfield,
                    currentPlayerID: card.benchPlayerIDs.indices.contains(index) ? card.benchPlayerIDs[index] : nil,
                    slotLabel: { playerID in card.placementLabel(for: playerID, excluding: .bench(index)) }
                ) { selectedID in
                    card.assign(selectedID, to: .bench(index))
                }
            }
        }
        .alert(calendarAlertMessage ?? "", isPresented: $showCalendarAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private func addToCalendar() {
        Task {
            do {
                try await CalendarService.addFixtureToCalendar(for: card)
                calendarAlertMessage = "Added to your calendar."
            } catch {
                calendarAlertMessage = error.localizedDescription
            }
            showCalendarAlert = true
        }
    }

    @MainActor
    private func exportAndShare() {
        let exportView = ExportCardView(card: card, playerStore: playerStore)

        // JPEG, not PNG: smaller and faster to send in chat apps like WhatsApp,
        // which re-encode shared images anyway. Safe here since the card has an
        // opaque background — no transparency to lose.
        guard let uiImage = exportView.renderedToImage(width: 400),
              let jpegData = uiImage.jpegData(compressionQuality: 0.92) else { return }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Lineup-\(card.id.uuidString)")
            .appendingPathExtension("jpg")

        do {
            try jpegData.write(to: tempURL, options: .atomic)
            // Presented directly via UIKit rather than a SwiftUI .sheet — the
            // .sheet-wrapped form of UIActivityViewController is a well-known
            // source of a blank/white share sheet on real devices.
            ActivityShareSheet.present(items: [tempURL])
        } catch {
            // Nothing sensible to recover to here; sharing simply won't happen.
        }
    }
}
