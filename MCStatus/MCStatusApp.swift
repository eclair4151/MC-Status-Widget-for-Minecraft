//
//  MCStatusApp.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 6/27/23.
//

import SwiftUI
import SwiftData
import MCStatusDataLayer
import AppIntents

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
