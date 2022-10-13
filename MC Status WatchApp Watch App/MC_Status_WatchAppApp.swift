//
//  MC_Status_WatchAppApp.swift
//  MC Status WatchApp Watch App
//
//  Created by Tomer Shemesh on 10/13/22.
//  Copyright © 2022 ShemeshApps. All rights reserved.
//

import SwiftUI

@main
struct MC_Status_WatchApp_Watch_AppApp: App {

    
    @ObservedObject private var session = WatchSessionManager()
    var body: some Scene {
        WindowGroup {
            ContentView(appData: session.appData)
        }
    }
}
