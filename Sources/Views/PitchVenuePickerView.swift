import SwiftUI

struct PitchVenuePickerView: View {
    var selectedID: String?
    var onSelect: (PitchVenue) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(PitchVenue.catalog) { venue in
                Button {
                    onSelect(venue)
                } label: {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Color(hex: venue.colorHex))
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(venue.clubName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text("\(venue.groundName) · \(venue.location)")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if venue.id == selectedID {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color(hex: venue.colorHex))
                        }
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Choose a Pitch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    PitchVenuePickerView(selectedID: nil) { _ in }
}
