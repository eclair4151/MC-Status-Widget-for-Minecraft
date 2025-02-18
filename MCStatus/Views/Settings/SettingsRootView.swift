import SwiftUI
import MCStatusDataLayer

enum SettingsPageDestinations {
    case GeneralSettings,
         FAQ,
         Shortcuts,
         Siri,
         WhatsNew
}

struct SettingsRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    
    @State private var showingTipSheet = false
    
    var body: some View {
        Form {
            Section {
                // General Settings
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
                
                // What's New
                NavigationLink(value: SettingsPageDestinations.WhatsNew) {
                    Label("What's New", systemImage: "sparkles")
                }
            }
            
            Section {
                // Leave a Review
                Button(action: openGithub) {
                    Label("View the Source Code on GitHub", systemImage: "curlybraces")
                }
            } footer: {
                Text("See the code that makes this app work, as well as file bugs and feature requests")
            }
            
            Section {
                // Leave a Review
                Button(action: leaveAppReview) {
                    Label("Leave an App Review", systemImage: "star")
                }
            } footer: {
                Text("Leave a review to help others discover the app and support its development")
            }
            
            Section {
                // Tip Developer
                Button(action: tipDeveloper) {
                    Label("Leave Developer a Tip", systemImage: "giftcard")
                }
            } footer: {
                Text("Help support the development of free, adless, open source apps")
            }
            
            Section {
                // Join TestFlight
                Button(action: joinTestFlight) {
                    Label("Join TestFlight", systemImage: "airplane")
                }
            } footer: {
                Text("Join the beta program to access experimental features before they’re released")
            }
#if DEBUG
            Section("Debug") {
                Button("Inject servers") {
                    injectServers()
                }
            }
#endif
        }
        .sheet($showingTipSheet) {
            NavigationStack {
                TipJarView($showingTipSheet)
            }
        }
        .navigationTitle("Settings")
        .background(Color(.systemGroupedBackground))
    }
    
    private func openGithub() {
        let url = "https://github.com/TopScrech/MC-Stats"
        
        guard let githubUrl = URL(string: url) else {
            print("Expected a valid URL")
            return
        }
        
        openURL(githubUrl)
    }
    
    private func joinTestFlight() {
        let url = "https://testflight.apple.com/join/CCYB35PS"
        
        guard let testflightUrl = URL(string: url) else {
            print("Expected a valid URL")
            return
        }
        
        openURL(testflightUrl)
    }
    
    private func leaveAppReview() {
        // Replace the placeholder value below with the App Store ID for your app.
        // You can find the App Store ID in your app's product URL.
        let url = "https://apps.apple.com/app/id1408215245?action=write-review"
        
        guard let writeReviewURL = URL(string: url) else {
            print("Expected a valid URL")
            return
        }
        
        openURL(writeReviewURL)
    }
    
    private func tipDeveloper() {
        showingTipSheet = true
    }
    
    private func injectServers() {
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
