import Foundation
import AppIntents

//converted for widget from previous intent
struct ServerSelectNoThemeWidgetIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ServerSelectNoThemeIntent"
    
    static var title: LocalizedStringResource = "Server Select"
    static var description: IntentDescription = "Select which server to show"
    
    @Parameter(title: "Server")
    var Server: ServerIntentTypeAppEntity?
    
    static var parameterSummary: some ParameterSummary {
        Summary()
    }
}
