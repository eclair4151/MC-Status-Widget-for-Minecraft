import Foundation
import AppIntents

// Converted for widget from previous intent
struct SelectServerIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ServerSelectIntent"
    
    static var title: LocalizedStringResource = "Server Select"
    static var description: IntentDescription = "Select which server to show"
    
    // Not for shortcuts
    static var isDiscoverable = false
    
    @Parameter(title: "Server")
    var Server: ServerIntentTypeAppEntity?
    
    @Parameter(title: "Theme")
    var Theme: ThemeIntentTypeAppEntity?
    
    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$Server
            \.$Theme
        }
    }
}
