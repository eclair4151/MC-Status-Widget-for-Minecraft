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
        Form {
            Section() {
                // General Options
                NavigationLink(destination: GeneralSettingsView()) {
                    Label("General Settings", systemImage: "gear")
                }
                
                // FAQ
                NavigationLink(destination: FAQView()) {
                    Label("FAQ", systemImage: "questionmark.circle")
                }
                
                // Shortcuts
                NavigationLink(destination: ShortcutsView()) {
                    Label("Shortcuts", systemImage: "link")
                }
                
                // Siri
                NavigationLink(destination: SiriSettingsView()) {
                    Label("Siri", systemImage: "mic")
                }
            }
            
           
           
           Section(footer: Text("Leave a review to help others discover the app and support its development.")) {
               // Leave a Review
               Button(action: leaveAppReview) {
                   Label("Leave an App Review", systemImage: "star")
               }
           }
           
           Section(footer: Text("Help support the development of free, adless, open source apps.")) {
               // Tip Developer
               Button(action: tipDeveloper) {
                   Label("Tip Developer $1.99", systemImage: "giftcard")
               }
           }
            
            Section(footer: Text("Join the beta program to access experimental features before they’re released.")) {
               // Join TestFlight
               Button(action: joinTestFlight) {
                   Label("Join TestFlight", systemImage: "airplane")
               }
           }
        }
        .navigationTitle("Settings")
        .background(Color(.systemGroupedBackground))
        Button("Inject servers") {
            injectServers()
        }
        
    }
    
    // Action methods
        func joinTestFlight() {
            // Code to handle TestFlight joining
        }
        
        func leaveAppReview() {
            // Code to handle leaving a review
        }
        
        func tipDeveloper() {
            // Code to handle tipping
        }
    
    func injectServers() {
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




// General Settings Sub-View
struct GeneralSettingsView: View {
    @State private var toggle1 = true
    @State private var toggle2 = true
    @State private var toggle3 = true

    var body: some View {
        Form {
            Toggle(isOn: $toggle1) {
                           VStack(alignment: .leading, spacing: 2) {
                               Text("Enable iCloud Syncing")
                               Text("Sync your server list across all devices.")
                                   .font(.footnote)
                                   .foregroundColor(.gray)
                           }
                       }
                       
                       // Show users on homescreen Toggle
                       Toggle(isOn: $toggle2) {
                           VStack(alignment: .leading, spacing: 2) {
                               Text("Show users on homescreen")
                               Text("Show users in each row on the homescreen")
                                   .font(.footnote)
                                   .foregroundColor(.gray)
                           }
                       }
                       
                       // Sort users by name Toggle
                       Toggle(isOn: $toggle3) {
                           VStack(alignment: .leading, spacing: 2) {
                               Text("Sort users alphabetically")
                               Text("Show users sorted alphabetically instead of randomly")
                                   .font(.footnote)
                                   .foregroundColor(.gray)
                           }
                       }
        }
        .navigationTitle("General Settings")
    }
    
   
}

// FAQ Sub-View
struct FAQView: View {
    var body: some View {
        Text("Frequently Asked Questions")
            .navigationTitle("FAQ")
    }
}

// Shortcuts Sub-View
struct ShortcutsView: View {
    var body: some View {
        Text("Shortcuts for faster access")
            .navigationTitle("Shortcuts")
    }
}

// Siri Settings Sub-View
struct SiriSettingsView: View {
    var body: some View {
        Text("Siri Settings and Customizations")
            .navigationTitle("Siri")
    }
}


#Preview {
    GeneralSettingsView()
}





