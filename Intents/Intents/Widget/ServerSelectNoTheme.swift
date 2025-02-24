import Foundation
import AppIntents

// Converted for widget from previous intent
struct ServerSelectNoThemeWidgetIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ServerSelectNoThemeIntent"
    
    static var title: LocalizedStringResource = "Server Select"
    static var description: IntentDescription = "Select which server to show"
    
    @Parameter(title: "Server")
    var Server: ServerIntentTypeAppEntity?
    
    @Parameter(title: "Show max player count", description: "Displays the max player count alongside the current number of players in the widgets", default: true)
    var showMaxPlayerCount: Bool
    
    static var parameterSummary: some ParameterSummary {
        Summary()
    }
}
