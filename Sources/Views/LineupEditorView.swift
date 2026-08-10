import SwiftUI
import PhotosUI
import UIKit

struct LineupEditorView: View {
    let cardID: UUID

    @EnvironmentObject private var store: LineupStore
    @EnvironmentObject private var playerStore: PlayerStore
    @Environment(\.dismiss) private var dismiss

    @State private var card: LineupCard = LineupCard(formation: Formation.presets[0])
    @State private var color: Color = .init(hex: "#1E6B45")
    @State private var logoItem: PhotosPickerItem?
    @State private var shareURL: URL?
    @State private var showShareSheet = false
    @State private var showPitchPicker = false
    @State private var loaded = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                PitchView(formation: card.formation, playerIDs: $card.playerIDs, playerStore: playerStore, accentColor: color, pitchColor: Color(hex: card.pitchVenue.colorHex))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge, style: .continuous))
                    .elevatedShadow()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                VStack(spacing: 12) {
                    TextField("Club name", text: $card.clubName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16, weight: .medium))

                    Divider()

                    TextField("vs Opponent — Sat 15 Nov, Home", text: $card.matchSubtitle)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                }
                .groupedCard()
                .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    HStack {
                        Label("Team Colour", systemImage: "paintpalette.fill")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        ColorPicker("", selection: $color, supportsOpacity: false)
                            .labelsHidden()
                    }

                    Divider()

                    HStack {
                        PhotosPicker(selection: $logoItem, matching: .images) {
                            Label(card.logoImageData == nil ? "Add Club Logo" : "Change Club Logo", systemImage: "photo.fill")
                                .font(.system(size: 15, weight: .medium))
                        }
                        Spacer()
                        if let data = card.logoImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        }
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

                Button {
                    exportAndShare()
                } label: {
                    Label("Share Lineup", systemImage: "square.and.arrow.up.fill")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundColor(.white)
                .background(Theme.accentGradient(color), in: RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous))
                .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
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
                color = Color(hex: existing.colorHex)
            } else {
                card.id = cardID
            }
            loaded = true
        }
        .onChange(of: card) { _, newValue in
            store.upsert(newValue)
        }
        .onChange(of: color) { _, newValue in
            card.colorHex = newValue.hexString
        }
        .onChange(of: logoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    card.logoImageData = data
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareURL {
                ActivityShareSheet(items: [shareURL])
            }
        }
        .sheet(isPresented: $showPitchPicker) {
            PitchVenuePickerView(selectedID: card.pitchVenueID) { venue in
                card.pitchVenueID = venue.id
                showPitchPicker = false
            }
        }
    }

    @MainActor
    private func exportAndShare() {
        let exportView = ExportCardView(card: card, playerStore: playerStore)
        let renderer = ImageRenderer(content: exportView)
        renderer.scale = 3

        // JPEG, not PNG: smaller and faster to send in chat apps like WhatsApp,
        // which re-encode shared images anyway. Safe here since the card has an
        // opaque background — no transparency to lose.
        guard let uiImage = renderer.uiImage, let jpegData = uiImage.jpegData(compressionQuality: 0.92) else { return }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Lineup-\(card.id.uuidString)")
            .appendingPathExtension("jpg")

        do {
            try jpegData.write(to: tempURL, options: .atomic)
            shareURL = tempURL
            showShareSheet = true
        } catch {
            // Nothing sensible to recover to here; sharing simply won't happen.
        }
    }
}
