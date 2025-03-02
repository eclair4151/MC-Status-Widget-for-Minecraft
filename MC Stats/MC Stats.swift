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
            .frame(width: 800, height: 600)
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
#endif
    }
}
