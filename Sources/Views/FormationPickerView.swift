import SwiftUI

struct FormationPickerView: View {
    var onSelect: (Formation) -> Void

    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Formation.presets) { formation in
                        Button {
                            onSelect(formation)
                        } label: {
                            FormationThumbnail(formation: formation)
                        }
                        .buttonStyle(PressableCardStyle())
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Choose a Formation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct FormationThumbnail: View {
    var formation: Formation

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                GeometryReader { geo in
                    ForEach(formation.positions) { position in
                        Circle()
                            .fill(.white)
                            .frame(width: 9, height: 9)
                            .shadow(color: .black.opacity(0.3), radius: 1.5, x: 0, y: 1)
                            .position(
                                x: geo.size.width * position.x,
                                y: geo.size.height * (1 - position.y)
                            )
                    }
                }
            }
            .aspectRatio(0.7, contentMode: .fit)
            .background(Theme.pitchGradient(base: Color(hex: "#1E7A46")))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall, style: .continuous))

            Text(formation.name)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .elevatedShadow()
    }
}

#Preview {
    FormationPickerView { _ in }
}
