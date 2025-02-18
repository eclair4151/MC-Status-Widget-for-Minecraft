import ScrechKit
import MCStatusDataLayer

@main
struct MCStatusApp: App {
    init() {
        print("Main App Init")
    }
    
    var body: some Scene {
        WindowGroup {
            MainAppContentView()
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
    }
}
