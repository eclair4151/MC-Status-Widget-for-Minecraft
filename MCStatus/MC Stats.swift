import ScrechKit
import MCStatusDataLayer

@main
struct MCStatusApp: App {
    var body: some Scene {
        WindowGroup {
            MainAppContentView()
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
    }
}
