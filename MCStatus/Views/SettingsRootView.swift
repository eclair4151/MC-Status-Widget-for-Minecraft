//
//  SettingsRootView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/13/23.
//

import SwiftUI
import MCStatusDataLayer
import AppIntents


enum SettingsPageDestinations {
    case GeneralSettings
    case FAQ
    case Shortcuts
    case Siri
    
}

struct SettingsRootView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @State private var showingTipSheet = false

    var body: some View {
        Form {
            Section() {
                //GeneralSettingsView
                NavigationLink(value: SettingsPageDestinations.GeneralSettings) {
                    Label("General Settings", systemImage: "gear")
                }
                
                // FAQ
                NavigationLink(value: SettingsPageDestinations.FAQ) {
                    Label("FAQ", systemImage: "questionmark.circle")
                }
                
                // Shortcuts
                NavigationLink(value: SettingsPageDestinations.Shortcuts) {
                    Label("Shortcuts", systemImage: "link")
                }
                
                // Siri
                NavigationLink(value: SettingsPageDestinations.Siri) {
                    Label("Siri", systemImage: "mic")
                }
                
            }
            
            Section(footer: Text("See the code that makes this app work, as well as file bugs and feature reqesusts.")) {
                // Leave a Review
                Button(action: openGithub) {
                    Label("View the Source Code on GitHub", systemImage: "curlybraces")
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
        .sheet(isPresented: $showingTipSheet) {
            NavigationStack {
                TipJarView(isPresented: $showingTipSheet)
            }
        }
        .navigationTitle("Settings")
        .background(Color(.systemGroupedBackground))
//        Button("Inject servers") {
//            injectServers()
//        }
        
    }

    func openGithub() {
        let url = "https://github.com/eclair4151/MC-Status-Widget-for-Minecraft/"
        guard let githubUrl = URL(string: url) else {
            print("Expected a valid URL")
            return
        }
        openURL(githubUrl)
    }
    

    func joinTestFlight() {
            let url = "https://testflight.apple.com/join/k9RmbbJI"
            guard let testflightUrl = URL(string: url) else {
                print("Expected a valid URL")
                return
            }
            openURL(testflightUrl)
        }
        
        func leaveAppReview() {
            // Replace the placeholder value below with the App Store ID for your app.
            // You can find the App Store ID in your app's product URL.
            let url = "https://apps.apple.com/app/id1408215245?action=write-review"
            guard let writeReviewURL = URL(string: url) else {
                print("Expected a valid URL")
                return
            }
            openURL(writeReviewURL)
        }
        
        func tipDeveloper() {
            showingTipSheet = true
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
    @AppStorage(UserDefaultHelper.Key.iCloudEnabled.rawValue) var toggle1 = true
    @AppStorage(UserDefaultHelper.Key.showUsersOnHomesreen.rawValue) var toggle2 = true
    @AppStorage(UserDefaultHelper.Key.sortUsersByName.rawValue) var toggle3 = true
//
//    @State var toggle1 = true
//    @State var toggle2 = true
//    @State var toggle3 = true

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

//// FAQ Sub-View
//struct FAQView: View {
//    var body: some View {
//        Text("Frequently Asked Questions")
//            .navigationTitle("FAQ")
//    }
//}

// Shortcuts Sub-View
struct ShortcutsView: View {
    var body: some View {
        Text("Shortcuts for faster access")
            .navigationTitle("Shortcuts")
        ShortcutsLink()
            .shortcutsLinkStyle(ShortcutsLinkStyle.automaticOutline)
    }
}

// Siri Settings Sub-View
struct SiriSettingsView: View {
    @State var tipVisibility = true
    var body: some View {
        Text("Siri Settings and Customizations")
            .navigationTitle("Siri")
    }
}


#Preview {
    GeneralSettingsView()
}





