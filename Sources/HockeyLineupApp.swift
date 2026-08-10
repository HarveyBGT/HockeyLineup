import SwiftUI

@main
struct HockeyLineupApp: App {
    @StateObject private var store = LineupStore()
    @StateObject private var playerStore = PlayerStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(playerStore)
        }
    }
}
