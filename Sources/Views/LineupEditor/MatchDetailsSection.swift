import SwiftUI

/// Opposition, date/time, home/away, and the "Add to Calendar" action.
struct MatchDetailsSection: View {
    @Binding var card: LineupCard
    var accentColor: Color
    var onAddToCalendar: () -> Void

    private var matchDateBinding: Binding<Date> {
        Binding(
            get: { card.matchDate ?? Date() },
            set: { card.matchDate = $0 }
        )
    }

    var body: some View {
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

            Button(action: onAddToCalendar) {
                Label("Add to Calendar", systemImage: "calendar.badge.plus")
                    .font(.system(size: 15, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundStyle(card.matchDate == nil ? Color.secondary : Theme.fortressBlue)
            .disabled(card.matchDate == nil)
        }
        .groupedCard()
        .padding(.horizontal, 16)
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
                .modifier(GlassTogglePillBackground(isSelected: isSelected, tint: accentColor))
        }
        .buttonStyle(.plain)
    }
}
