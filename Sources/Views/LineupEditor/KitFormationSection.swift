import SwiftUI

/// Home/away kit colours, formation choice, and the pitch venue picker.
struct KitFormationSection: View {
    @Binding var card: LineupCard
    @Binding var homeColor: Color
    @Binding var awayColor: Color
    var onPitchTap: () -> Void

    var body: some View {
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

            Button(action: onPitchTap) {
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
    }
}
