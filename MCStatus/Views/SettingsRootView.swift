//
//  SettingsRootView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/13/23.
//

import SwiftUI
import MCStatusDataLayer


//Show tip view
//Use SiriTipView
//
//SiriTipView(intent: ReorderIntent(), isVisible: $isVisible)
//    .siriTipViewStyle(.black)
//Show link to open Shortcuts app
//Use ShortcutsLink
//
//ShortcutsLink()
//     .shortcutsLinkStyle(.whiteOutline)

struct SettingsRootView: View {
    
    @Environment(\.modelContext) private var modelContext

    
    var body: some View {
        Text("Settings")
        Button("Inject servers") {
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Insanity Craft", serverUrl: "join.insanitycraft.net", serverPort: 25565))
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "OpBlocks", serverUrl: "hub.opblocks.com", serverPort: 25565))
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Ace MC", serverUrl: "mc.acemc.co", serverPort: 25565))
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Vanilla Realms", serverUrl: "mcs.vanillarealms.com", serverPort: 25565))
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Earth MC", serverUrl: "org.earthmc.net", serverPort: 25565))
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Zero's Server", serverUrl: "zero.minr.org", serverPort: 25565))
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Rainy Day", serverUrl: "rainyday.gg", serverPort: 25565))
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Java, name: "Harmony Server", serverUrl: "join.harmonyfallssmp.world", serverPort: 25565))
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Bedrock, name: "Fade Cloud", serverUrl: "mp.fadecloud.com", serverPort: 19132))
            modelContext.insert(SavedMinecraftServer.initialize(id: UUID(), serverType: .Bedrock, name: "MC Hub", serverUrl: "mps.mchub.com", serverPort: 19132))
            
            do {
                // Try to save
                try modelContext.save()
            } catch {
                // We couldn't save :(
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    SettingsRootView()
}
