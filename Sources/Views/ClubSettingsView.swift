import SwiftUI

/// Lets any club in the division point the app at themselves instead of
/// Barnes — picks `MyTeam.teamID`/`pitchVenueID` from the existing
/// `LeagueData`/`PitchVenue` catalogues. Only reconfigures the main app;
/// see the note on `MyTeam` for why the widget/Watch don't pick this up
/// automatically.
struct ClubSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var teamID: String = MyTeam.teamID
    @State private var pitchVenueID: String = MyTeam.pitchVenueID ?? PitchVenue.classicGreen.id
    /// Called after a successful save — lets `WelcomeView` know first-run
    /// setup is done, without this view needing to know about onboarding.
    var onSave: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("My Team", selection: $teamID) {
                        ForEach(LeagueData.teams) { team in
                            Text(team.name).tag(team.id)
                        }
                    }
                } footer: {
                    Text("Changes which club's crest, kit defaults, and fixture list the app builds lineups for. Existing saved lineups keep their own details.")
                }

                Section {
                    Picker("Home Pitch", selection: $pitchVenueID) {
                        ForEach(PitchVenue.catalog) { venue in
                            Text(venue.clubName).tag(venue.id)
                        }
                    }
                } footer: {
                    Text("Used as the default venue for home fixtures.")
                }
            }
            .navigationTitle("Club Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        MyTeam.teamID = teamID
                        MyTeam.pitchVenueID = pitchVenueID
                        dismiss()
                        onSave?()
                    }
                }
            }
        }
    }
}

#Preview {
    ClubSettingsView()
}
