import SwiftUI

@main
struct HockeyLineupApp: App {
    @StateObject private var store = LineupStore()
    @StateObject private var playerStore = PlayerStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(playerStore)
        }
        // Saves are debounced (see LineupStore/PlayerStore) so rapid typing
        // doesn't rewrite the whole file on every keystroke — flush
        // immediately here so backgrounding mid-edit never loses the last,
        // still-pending change.
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                store.flush()
                playerStore.flush()
            }
        }
    }
}
