import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LineupStore
    @State private var showFormationPicker = false
    @State private var showPlayerDatabase = false
    @State private var selectedCardID: UUID?

    private var sortedCards: [LineupCard] {
        store.cards.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.cards.isEmpty {
                    ContentUnavailableView {
                        Label("No Lineups Yet", systemImage: "sportscourt")
                    } description: {
                        Text("Tap + to build your first hockey lineup graphic.")
                    } actions: {
                        Button("New Lineup") { showFormationPicker = true }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(hex: "#1E7A46"))
                    }
                } else {
                    ScrollView {
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
                        .padding(16)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("My Lineups")
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
}

private struct LineupRow: View {
    var card: LineupCard

    private var color: Color { Color(hex: card.colorHex) }

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
                if !card.matchSubtitle.isEmpty {
                    Text(card.matchSubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .elevatedShadow()
        .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous))
    }
}

#Preview {
    ContentView()
        .environmentObject(LineupStore())
}
