import WidgetKit
import SwiftUI

@main
struct FortressWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextFixtureWidget()
        MatchLiveActivityWidget()
    }
}
