import SwiftUI

struct SiriPhrase: Identifiable {
    let id = UUID()
    let phrase: String
}

struct SiriGuideView: View {
    private let phrases = [
        SiriPhrase(phrase: "Check the status of my (Minecraft) server"),
        SiriPhrase(phrase: "What's the status of my (Minecraft) server"),
        SiriPhrase(phrase: "Check the status of [SERVER NAME]"),
        SiriPhrase(phrase: "What's the status of [SERVER NAME]"),
        SiriPhrase(phrase: "Check [SERVER NAME]'s status for me"),
    ]
    
    @State private var tipVisibility = true
    
    var body: some View {
        Form {
            // Looks bad dont bother using build in view
            // SiriTipView(intent: SavedServerStatusOnlineCheckIntent(), isVisible: $tipVisibility)
            Section {
                ForEach(phrases) { phrase in
                    SiriGuidePhrase(phrase)
                }
            } header: {
                Text("How to Use Siri with MC Status")
                    .title2(.bold)
                    .padding(.bottom, 5)
            }
            .headerProminence(.increased)
        }
        .navigationTitle("Siri")
#if !os(tvOS)
        .background(Color(.systemGroupedBackground))
#endif
    }
}
