//
//  ServerSelect.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/28/23.
//

import Foundation
import AppIntents

//converted for widget from previous intent
//struct ServerSelect: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent, PredictableIntent {
//    static let intentClassName = "ServerSelectIntent"
//
//    static var title: LocalizedStringResource = "Server Select"
//    static var description = IntentDescription("Select which server to show")
//
//    // hide this since it is only for the widget not for shortcuts
//    static var isDiscoverable = false
//    
//    @Parameter(title: "Server")
//    var Server: ServerIntentTypeAppEntity?
//
//    @Parameter(title: "Theme")
//    var Theme: ThemeIntentTypeAppEntity?
//
//    static var parameterSummary: some ParameterSummary {
//        Summary {
//            \.$Server
//            \.$Theme
//        }
//    }
//
//    static var predictionConfiguration: some IntentPredictionConfiguration {
//        IntentPrediction(parameters: (\.$Server, \.$Theme)) { Server, Theme in
//            DisplayRepresentation(
//                title: "",
//                subtitle: ""
//            )
//        }
//    }
//
//    func perform() async throws -> some IntentResult {
//        // TODO: Place your refactored intent handler code here.
//        return .result()
//    }
//}

//fileprivate extension IntentDialog {
//    static func ServerParameterDisambiguationIntro(count: Int, Server: ServerIntentTypeAppEntity) -> Self {
//        "There are \(count) options matching ‘\(Server)’."
//    }
//    static func ServerParameterConfirmation(Server: ServerIntentTypeAppEntity) -> Self {
//        "Just to confirm, you wanted ‘\(Server)’?"
//    }
//    static func ThemeParameterDisambiguationIntro(count: Int, Theme: ThemeIntentTypeAppEntity) -> Self {
//        "There are \(count) options matching ‘\(Theme)’."
//    }
//    static func ThemeParameterConfirmation(Theme: ThemeIntentTypeAppEntity) -> Self {
//        "Just to confirm, you wanted ‘\(Theme)’?"
//    }
//}

