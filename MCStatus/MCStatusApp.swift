//
//  MCStatusApp.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 6/27/23.
//

import SwiftUI
import SwiftData

let config = ModelConfiguration(nil, schema: Schema ([SavedMinecraftServer.self]), inMemory: false, readOnly: false, groupContainer: ModelConfiguration.GroupContainer.identifier("group.shemeshapps.MinecraftServerStatus"), cloudKitDatabase: ModelConfiguration.CloudKitDatabase.private("com.shemeshapps.mcstatus"))


@main
struct MCStatusApp: App {

    var body: some Scene {
        WindowGroup {
            MainAppContentView()
        }
        .modelContainer(try! ModelContainer(for: SavedMinecraftServer.self, config))
    }
}


