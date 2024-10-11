//
//  ServerSelect.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/28/23.
//

import Foundation
import AppIntents

//converted for widget from previous intent
struct ServerSelectWidgetIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ServerSelectIntent"

    static var title: LocalizedStringResource = "Server Select"
    static var description = IntentDescription("Select which server to show")

    // hide this since it is only for the widget not for shortcuts
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
    func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        return .result()
    }
}

