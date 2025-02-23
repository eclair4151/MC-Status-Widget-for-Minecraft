import SwiftUI
import StoreKit
import MCStatusDataLayer

enum SettingsPageDestinations {
    case GeneralSettings, FAQ, Shortcuts, Siri, WhatsNew
}

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    
    private let reloadServers: () -> Void
    
    init(reloadServers: @escaping () -> Void = {}) {
        self.reloadServers = reloadServers
    }
    
    @State private var showingTipSheet = false
    
    var body: some View {
        Form {
            Section {
                Text("Powered by **[Bisquit.Host](https://bisquit.host)**")
                    .tint(.orange)
            }
            
            Section {
                // General Settings
                NavigationLink(value: SettingsPageDestinations.GeneralSettings) {
                    Label("General Settings", systemImage: "gear")
                }
                
                // FAQ
                NavigationLink(value: SettingsPageDestinations.FAQ) {
                    Label("FAQ", systemImage: "exclamationmark.questionmark")
                }
#if !os(tvOS)
                // Shortcuts
                NavigationLink(value: SettingsPageDestinations.Shortcuts) {
                    Label("Shortcuts", systemImage: "link")
                }
                
                // Siri
                NavigationLink(value: SettingsPageDestinations.Siri) {
                    Label("Siri", systemImage: "mic")
                }
#endif
                // What's New
                NavigationLink(value: SettingsPageDestinations.WhatsNew) {
                    Label("Features", systemImage: "sparkles")
                }
            }
#if !os(tvOS)
            // Leave a Review
            Section {
                Button(action: leaveAppReview) {
                    Label {
                        Text("Leave an App Review")
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow.gradient)
                    }
                }
            } footer: {
                Text("Leave a review to help others discover the app and support its development")
            }
            
#warning("In-App Purchases")
            //            Section {
            //                // Tip Developer
            //                Button(action: tipDeveloper) {
            //                    Label("Leave Developer a Tip", systemImage: "gift")
            //                }
            //            } footer: {
            //                Text("Help support the development of free, adless, open source apps")
            //            }
            
            // Join TestFlight
            Section {
                Button(action: joinTestFlight) {
                    Label {
                        Text("Join TestFlight")
                    } icon: {
                        Image(.testFlight)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(.rect(cornerRadius: 6))
                    }
                }
            } footer: {
                Text("Join the beta program to access experimental features before they’re released")
            }
            
            // GitHub
            Section {
                Button(action: openGithub) {
                    Label("Source Code", systemImage: "curlybraces")
                }
            } footer: {
                Text("See the code that makes this app work, as well as file bugs and feature requests. Forked from [eclair4151's MC-Status](https://github.com/eclair4151/MC-Status-Widget-for-Minecraft)")
            }
#endif
            DebugSettings {
                reloadServers()
            }
        }
        .navigationTitle("Settings")
        .scrollIndicators(.never)
        .sheet($showingTipSheet) {
            NavigationStack {
                TipJarView($showingTipSheet)
            }
        }
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
#if os(tvOS)
        let url = "https://apps.apple.com/app/6740754881?action=write-review"
        
        guard let writeReviewURL = URL(string: url) else {
            print("Expected a valid URL")
            return
        }
        
        openURL(writeReviewURL)
#else
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        SKStoreReviewController.requestReview(in: windowScene)
#endif
    }
    
    private func tipDeveloper() {
        showingTipSheet = true
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
