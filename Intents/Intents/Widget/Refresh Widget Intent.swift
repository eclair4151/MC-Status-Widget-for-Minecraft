import AppIntents

struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Widget"
    static var isDiscoverable = false
    
    func perform() async throws -> some IntentResult {
        // try await Task.sleep(nanoseconds: UInt64(10) * NSEC_PER_SEC)
        .result()
    }
}
