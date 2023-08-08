//
//  MinecraftServerStatusApp.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 6/27/23.
//

import SwiftUI
import SwiftData

@main
struct MinecraftServerStatusApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
