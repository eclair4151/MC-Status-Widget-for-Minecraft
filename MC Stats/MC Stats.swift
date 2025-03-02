import ScrechKit
import MCStatsDataLayer

@main
struct MCStatsApp: App {
    var body: some Scene {
        WindowGroup {
            AppContainer()
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
        
#if os(macOS)
        Settings {
            NavigationStack {
                SettingsView()
            }
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
#endif
    }
}
