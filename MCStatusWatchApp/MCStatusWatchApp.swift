//
//  MCStatusWatchAppApp.swift
//  MCStatusWatchApp Watch App
//
//  Created by Tomer Shemesh on 8/7/23.
//

import SwiftUI
import SwiftData

@main
struct MCStatusWatchApp_App: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
        .modelContainer(SwiftDataHelper.getModelContainter())
    }
}
