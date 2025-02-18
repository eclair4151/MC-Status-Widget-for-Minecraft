import SwiftUI
import MCStatusDataLayer

@main
struct MCStatsWatch: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
    }
}
