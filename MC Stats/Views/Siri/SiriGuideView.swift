import SwiftUI

struct SiriGuideView: View {
    private let phrases = [
        SiriPhrase("Check the status of my (Minecraft) server"),
        SiriPhrase("What's the status of my (Minecraft) server"),
        SiriPhrase("Check the status of [SERVER NAME]"),
        SiriPhrase("What's the status of [SERVER NAME]"),
        SiriPhrase("Check [SERVER NAME]'s status for me"),
    ]
    
    @State private var tipVisibility = true
    
    var body: some View {
        Form {
            // Looks bad, don't bother using build in view
            // SiriTipView(intent: SavedServerStatusOnlineCheckIntent(), isVisible: $tipVisibility)
            
            Section {
                ForEach(phrases) { phrase in
                    SiriGuidePhrase(phrase)
                }
            }
        }
        .navigationTitle("How to Use Siri")
#if !os(tvOS)
        .background(Color(.systemGroupedBackground))
#endif
    }
}
