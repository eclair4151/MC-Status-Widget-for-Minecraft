import ScrechKit
import MCStatsDataLayer

@main
struct MCStatsApp: App {
    var body: some Scene {
        WindowGroup {
            MainAppContentView()
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
    }
}
