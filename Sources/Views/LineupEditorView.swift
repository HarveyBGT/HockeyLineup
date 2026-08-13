import ActivityKit
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
    @State private var currentActivity: Activity<MatchActivityAttributes>?
    @State private var liveOurScore = 0
    @State private var liveOpponentScore = 0
    @State private var liveStatus = "Kickoff"

    private static let liveStatusOptions = ["Kickoff", "1st Half", "Half Time", "2nd Half", "Full Time"]

    /// The kit colour actually in effect right now, given home/away.
    private var color: Color { card.isHome ? homeColor : awayColor }

    private var matchDateBinding: Binding<Date> {
        Binding(
            get: { card.matchDate ?? Date() },
            set: { card.matchDate = $0 }
        )
    }

    private var homeScoreBinding: Binding<String> {
        Binding(
            get: { card.homeScore.map(String.init) ?? "" },
            set: { card.homeScore = Int($0) }
        )
    }

    private var awayScoreBinding: Binding<String> {
        Binding(
            get: { card.awayScore.map(String.init) ?? "" },
            set: { card.awayScore = Int($0) }
        )
    }

    private var homeScoreFieldLabel: String {
        card.isHome ? MyTeam.name : (card.opposition.isEmpty ? "Home" : card.opposition)
    }

    private var awayScoreFieldLabel: String {
        card.isHome ? (card.opposition.isEmpty ? "Away" : card.opposition) : MyTeam.name
    }

    private func liveScoreCounter(title: String, value: Int, onChange: @escaping (Int) -> Void) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            HStack(spacing: 10) {
                Button { onChange(-1) } label: {
                    Image(systemName: "minus.circle.fill")
                }
                Text("\(value)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .frame(minWidth: 28)
                Button { onChange(1) } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .font(.system(size: 20))
            .foregroundStyle(Theme.fortressBlue)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func scoreField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            TextField("–", text: text)
                .keyboardType(.numberPad)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(width: 44)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                PitchView(
                    formation: card.formation,
                    playerIDs: $card.playerIDs,
                    playerStore: playerStore,
                    accentColor: color,
                    pitchColor: Color(hex: card.pitchVenue.colorHex),
                    slotLabel: { index, playerID in slotLabel(for: playerID, excluding: .pitch(index)) },
                    onAssign: { index, newID in card.assign(newID, to: .pitch(index)) },
                    onSwap: { source, destination in card.swapOrMove(from: source, to: destination) }
                )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge, style: .continuous))
                    .elevatedShadow()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

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
                        autoFillSquad()
                    } label: {
                        Label("Auto-Fill", systemImage: "wand.and.stars")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .modifier(ProminentGlassButtonModifier())
                    .tint(Theme.fortressGold)
                    .disabled(fullyUnassignedSquad.isEmpty)
                }
                .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    TextField("Opposition", text: $card.opposition)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))

                    Divider()

                    DatePicker("Date & Time", selection: matchDateBinding, displayedComponents: [.date, .hourAndMinute])
                        .font(.system(size: 15, weight: .medium))

                    Divider()

                    HStack {
                        Text("Venue")
                            .font(.system(size: 15, weight: .medium))
                        Spacer()
                        homeAwayToggle
                    }

                    Divider()

                    Button {
                        addToCalendar()
                    } label: {
                        Label("Add to Calendar", systemImage: "calendar.badge.plus")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(card.matchDate == nil ? Color.secondary : Theme.fortressBlue)
                    .disabled(card.matchDate == nil)
                }
                .groupedCard()
                .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    HStack {
                        Text("Result")
                            .font(.system(size: 15, weight: .medium))
                        Spacer()
                        if let result = card.result {
                            Text(result.label.uppercased())
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(0.5)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Theme.resultColor(result), in: Capsule())
                        }
                    }

                    HStack(spacing: 14) {
                        scoreField(title: homeScoreFieldLabel, text: homeScoreBinding)
                        Text("–")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        scoreField(title: awayScoreFieldLabel, text: awayScoreBinding)
                        Spacer()
                    }
                }
                .groupedCard()
                .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    HStack {
                        Label("Match Day", systemImage: "dot.radiowaves.left.and.right")
                            .font(.system(size: 15, weight: .medium))
                        Spacer()
                        if currentActivity != nil {
                            Text("LIVE")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .tracking(0.5)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.red, in: Capsule())
                        }
                    }

                    if currentActivity == nil {
                        Button {
                            startLiveActivity()
                        } label: {
                            Label("Start Live Activity", systemImage: "play.circle.fill")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .modifier(ProminentGlassButtonModifier())
                        .disabled(card.opposition.isEmpty)

                        if card.opposition.isEmpty {
                            Text("Set an opposition to start a Live Activity.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        HStack(spacing: 16) {
                            liveScoreCounter(title: MyTeam.name, value: liveOurScore, onChange: adjustOurScore)
                            Text("–")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            liveScoreCounter(title: card.opposition, value: liveOpponentScore, onChange: adjustOpponentScore)
                        }

                        Picker("Status", selection: Binding(get: { liveStatus }, set: { setLiveStatus($0) })) {
                            ForEach(Self.liveStatusOptions, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)

                        Button(role: .destructive) {
                            endLiveActivity()
                        } label: {
                            Label("End Live Activity", systemImage: "stop.circle.fill")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .groupedCard()
                .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    HStack {
                        Label("Home Kit", systemImage: "paintpalette.fill")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        ColorPicker("", selection: $homeColor, supportsOpacity: false)
                            .labelsHidden()
                    }

                    Divider()

                    HStack {
                        Label("Away Kit", systemImage: "paintpalette")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        ColorPicker("", selection: $awayColor, supportsOpacity: false)
                            .labelsHidden()
                    }

                    Divider()

                    Menu {
                        ForEach(Formation.presets) { formation in
                            Button(formation.name) {
                                card.formationID = formation.id
                                card.conformPlayerIDsToFormation()
                            }
                        }
                    } label: {
                        HStack {
                            Label("Formation", systemImage: "square.grid.3x3.fill")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(card.formation.name)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Divider()

                    Button {
                        showPitchPicker = true
                    } label: {
                        HStack {
                            Label("Pitch", systemImage: "sportscourt.fill")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.primary)
                            Spacer()
                            if card.pitchVenue.id != PitchVenue.classicGreen.id {
                                ClubCrestView(crest: card.pitchVenue.crest, size: 20)
                            }
                            Text(card.pitchVenue.clubName)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .groupedCard()
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Super Subs")
                        .font(.system(size: 15, weight: .medium))

                    HStack(spacing: 10) {
                        ForEach(card.benchPlayerIDs.indices, id: \.self) { index in
                            BenchSlotView(
                                player: playerStore.player(id: card.benchPlayerIDs[index]),
                                accentColor: color,
                                isDropTarget: benchDragTargetIndex == index
                            )
                            .onTapGesture { editingBenchIndex = index }
                            .onDrag {
                                NSItemProvider(object: NSString(string: PlayerSlot.bench(index).dragPayload))
                            }
                            .dropDestination(for: String.self) { items, _ in
                                benchDragTargetIndex = nil
                                guard let payload = items.first, let sourceSlot = PlayerSlot(dragPayload: payload) else { return false }
                                card.swapOrMove(from: sourceSlot, to: .bench(index))
                                return true
                            } isTargeted: { targeted in
                                benchDragTargetIndex = targeted ? index : nil
                            }
                        }
                    }

                    Divider()

                    HStack {
                        Label("Coach", systemImage: "person.fill.checkmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        TextField("Name", text: $card.coachName)
                            .multilineTextAlignment(.trailing)
                    }

                    Divider()

                    HStack {
                        Label("Umpire 1", systemImage: "flag.checkered")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        TextField("Name", text: $card.umpireOneName)
                            .multilineTextAlignment(.trailing)
                    }

                    Divider()

                    HStack {
                        Label("Umpire 2", systemImage: "flag.checkered")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        TextField("Name", text: $card.umpireTwoName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .groupedCard()
                .padding(.horizontal, 16)

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
            reattachLiveActivity()
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
                    slotLabel: { playerID in slotLabel(for: playerID, excluding: .bench(index)) }
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

    /// Reattaches to an already-running Live Activity for this lineup (e.g.
    /// the app was relaunched mid-match) rather than losing track of it.
    private func reattachLiveActivity() {
        guard let activity = Activity<MatchActivityAttributes>.activities.first(where: { $0.attributes.opponentName == card.opposition }) else { return }
        currentActivity = activity
        liveOurScore = activity.content.state.ourScore
        liveOpponentScore = activity.content.state.opponentScore
        liveStatus = activity.content.state.statusText
    }

    private func startLiveActivity() {
        guard currentActivity == nil else { return }
        liveOurScore = card.isHome ? (card.homeScore ?? 0) : (card.awayScore ?? 0)
        liveOpponentScore = card.isHome ? (card.awayScore ?? 0) : (card.homeScore ?? 0)
        liveStatus = "Kickoff"

        let attributes = MatchActivityAttributes(opponentName: card.opposition, isHome: card.isHome, venueText: card.venueText)
        let state = MatchActivityAttributes.ContentState(ourScore: liveOurScore, opponentScore: liveOpponentScore, statusText: liveStatus)
        do {
            currentActivity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
        } catch {
            // Live Activities can be disabled system-wide by the user; nothing
            // else to do here — the score fields above still work as normal.
        }
    }

    private func pushLiveActivityUpdate() {
        guard let currentActivity else { return }
        let state = MatchActivityAttributes.ContentState(ourScore: liveOurScore, opponentScore: liveOpponentScore, statusText: liveStatus)
        Task { await currentActivity.update(.init(state: state, staleDate: nil)) }
    }

    private func adjustOurScore(by delta: Int) {
        liveOurScore = max(0, liveOurScore + delta)
        pushLiveActivityUpdate()
    }

    private func adjustOpponentScore(by delta: Int) {
        liveOpponentScore = max(0, liveOpponentScore + delta)
        pushLiveActivityUpdate()
    }

    private func setLiveStatus(_ status: String) {
        liveStatus = status
        pushLiveActivityUpdate()
    }

    private func endLiveActivity() {
        guard let currentActivity else { return }
        // Carry the final score back onto the saved lineup card.
        if card.isHome {
            card.homeScore = liveOurScore
            card.awayScore = liveOpponentScore
        } else {
            card.homeScore = liveOpponentScore
            card.awayScore = liveOurScore
        }
        let finalState = MatchActivityAttributes.ContentState(ourScore: liveOurScore, opponentScore: liveOpponentScore, statusText: "Full Time")
        Task { await currentActivity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .default) }
        self.currentActivity = nil
    }

    /// Squad members not currently placed anywhere in this lineup, in a
    /// sensible pick order: numbered players first (by number), then
    /// unnumbered players alphabetically.
    private var fullyUnassignedSquad: [Player] {
        playerStore.players
            .filter { card.slot(of: $0.id) == nil }
            .sorted {
                switch ($0.squadNumber, $1.squadNumber) {
                case let (a?, b?): return a < b
                case (nil, nil): return $0.fullName < $1.fullName
                case (nil, _): return false
                case (_, nil): return true
                }
            }
    }

    /// Fills every empty pitch position, then every empty bench slot, from
    /// the squad database — a quick starting point rather than tapping each
    /// spot individually. Skips anyone already placed; stops gracefully if
    /// the squad runs out before every spot is filled.
    private func autoFillSquad() {
        var pool = fullyUnassignedSquad

        for index in card.playerIDs.indices where card.playerIDs[index] == nil {
            guard !pool.isEmpty else { break }
            let role = card.formation.positions.first(where: { $0.id == index })?.role
            let pickIndex = bestCandidateIndex(in: pool, for: role)
            let player = pool.remove(at: pickIndex)
            card.assign(player.id, to: .pitch(index))
        }

        for index in card.benchPlayerIDs.indices where card.benchPlayerIDs[index] == nil {
            guard !pool.isEmpty else { break }
            let player = pool.removeFirst()
            card.assign(player.id, to: .bench(index))
        }
    }

    /// The best-matching pool index for `role`: someone whose preferred
    /// position matches, falling back to the goalkeeper flag for GK,
    /// falling back to whoever's next in the pick order.
    private func bestCandidateIndex(in pool: [Player], for role: PositionRole?) -> Int {
        guard let role else { return 0 }
        if let index = pool.firstIndex(where: { $0.preferredRole == role }) {
            return index
        }
        if role == .goalkeeper, let index = pool.firstIndex(where: { $0.isGoalkeeper }) {
            return index
        }
        return 0
    }

    /// Short label for where `playerID` is currently placed, unless that's
    /// `slot` itself (nothing to report — that's the position being edited).
    private func slotLabel(for playerID: UUID, excluding slot: PlayerSlot) -> String? {
        guard let currentSlot = card.slot(of: playerID), currentSlot != slot else { return nil }
        switch currentSlot {
        case .pitch(let index):
            let role = card.formation.positions.first(where: { $0.id == index })?.role
            return role.map { "On pitch — \($0.rawValue)" } ?? "On pitch"
        case .bench:
            return "On bench"
        }
    }

    private var homeAwayToggle: some View {
        HStack(spacing: 8) {
            homeAwayPill(title: "Home", isSelected: card.isHome) { card.isHome = true }
            homeAwayPill(title: "Away", isSelected: !card.isHome) { card.isHome = false }
        }
    }

    private func homeAwayPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .modifier(GlassTogglePillBackground(isSelected: isSelected, tint: color))
        }
        .buttonStyle(.plain)
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

/// A single optional bench-squad slot: empty state invites a tap, filled
/// state shows the player's avatar and surname.
private struct BenchSlotView: View {
    var player: Player?
    var accentColor: Color
    var isDropTarget: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(player == nil ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Theme.accentGradient(accentColor)))
                .frame(width: 40, height: 40)
                .overlay {
                    if let player {
                        PlayerAvatarView(avatar: player.avatar, size: 32)
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .overlay(Circle().stroke(Color(.separator), lineWidth: 1))
                .overlay(
                    Circle()
                        .stroke(Theme.fortressGold, lineWidth: 3)
                        .padding(-4)
                        .opacity(isDropTarget ? 1 : 0)
                )
                .scaleEffect(isDropTarget ? 1.12 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDropTarget)

            Text(player?.lastName.isEmpty == false ? player!.lastName : "—")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
