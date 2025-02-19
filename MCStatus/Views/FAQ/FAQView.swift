import SwiftUI

struct FAQView: View {
    private let faqs: [FAQ]
    
    init(_ faqs: [FAQ]) {
        self.faqs = faqs
    }
    
    var body: some View {
        Form {
            Section {
                ForEach(faqs) { faq in
                    FAQRow(faq)
                }
            }
        }
        .navigationTitle("FAQ")
#if !os(tvOS)
        .background(Color(.systemGroupedBackground))
#endif
    }
}

func getiOSFAQs() -> [FAQ] {
    var faqs = [
        FAQ("Can you add push notification/server analytics to the app?", answer: "These features require a server component, and would need to be a paid subscription service. This may become an option in the future"),
        FAQ("Why are some servers missing player lists?", answer: "Some servers have plugins to disable this feature or return custom messages and other content in place of player names. Servers older than 1.7 also need to add enable-query=true to their server.properties file to enable this feature. Additionally, bedrock servers do not support player lists"),
        FAQ("Why do servers only show 12 players?", answer: "The Minecraft Server Status protocol only supports returning 12 randomly selected online players"),
        FAQ("Can you increase the refresh rate of the widget?", answer: "The widget is already set to the maximum allowed refresh rate. Widgets can be manually refreshed by tapping the refresh icon"),
        FAQ("How do I report a bug/request a feature?", answer: "All bug reports and feature requests can be raised as an issue on the GitHub repository, linked on the previous page")
    ]
    
#if !targetEnvironment(macCatalyst)
    faqs.insert(FAQ("My Apple Watch isn't syncing", answer: "Make sure you have iCloud enabled on one of your devices. Data is synced automatically, but may be delayed under certain conditions controlled by the OS. If after 1 minute your data isn't synced, you can restart the watch to force a resync"), at: faqs.count)
#endif
    
    return faqs
}
