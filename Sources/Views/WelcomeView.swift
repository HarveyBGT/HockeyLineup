import SwiftUI

/// Shown once, on first launch, before any team has been configured —
/// otherwise a brand-new install silently opens on "Barnes M3," which reads
/// as someone else's app rather than an invitation to set up your own club.
struct WelcomeView: View {
    /// Called once the user has picked a club and the sheet has dismissed.
    var onFinished: () -> Void

    @State private var showClubPicker = false

    var body: some View {
        ZStack {
            Theme.heroGradient.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
                    .frame(width: 108, height: 108)
                    .glassCircle()

                VStack(spacing: 10) {
                    Text("FORTRESS")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.white)

                    Text("Build and share matchday hockey lineups — squads, formations, fixtures, and a graphic ready to send to the team.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                }

                Spacer()
                Spacer()

                VStack(spacing: 10) {
                    Button {
                        showClubPicker = true
                    } label: {
                        Label("Choose Your Club", systemImage: "shield.checkered")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .modifier(ProminentGlassButtonModifier())
                    .tint(Theme.fortressGold)

                    Text("You can change this any time in Club Settings.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showClubPicker) {
            ClubSettingsView(onSave: onFinished)
        }
    }
}

#Preview {
    WelcomeView { }
}
