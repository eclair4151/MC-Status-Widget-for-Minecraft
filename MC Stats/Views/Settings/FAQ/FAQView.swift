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
#if !os(tvOS) && !os(macOS)
        .background(Color(.systemGroupedBackground))
#endif
    }
}

func getiOSFAQs() -> [FAQ] {
    var faqs = [
        FAQ("Can you add push notification/server analytics to the app?", answer: "These features require a server component, and would need to be a paid subscription service. This may become an option in the future"),
        FAQ("Why do some servers not display player lists?", answer: "Some servers use plugins to disable this feature or replace player names with custom messages. Servers running versions older than 1.7 must set enable-query=true in server.properties to enable it. Additionally, Bedrock servers do not support player lists"),
        FAQ("Why do Minecraft servers display only 12 online players?", answer: "The Minecraft Server Status protocol returns a maximum of 12 randomly selected online players"),
        FAQ("Can the widgets refresh more frequently?", answer: "The widgets are already set to the maximum allowed refresh rate. Widgets can be manually refreshed by tapping the refresh button"),
        FAQ("How do I report a bug/request a feature?", answer: "All bug reports and feature requests can be raised as an issue on the [GitHub repository](https://github.com/TopScrech/MC-Stats)")
    ]
    
#if !targetEnvironment(macCatalyst)
    faqs.insert(FAQ("My Apple Watch isn't syncing", answer: """
Data is synced automatically, but may be delayed under certain conditions controlled by the OS
    1. Make sure you have iCloud enabled on one of your devices
    2. If your data hasn’t synced within a minute, try restarting your watch to force a resync
"""), at: faqs.count)
#endif
    
    return faqs
}
