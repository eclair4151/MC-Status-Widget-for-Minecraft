import ScrechKit
import MCStatusDataLayer

@main
struct MCStatsApp: App {
    var body: some Scene {
        WindowGroup {
            MainAppContentView()
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
    }
}
