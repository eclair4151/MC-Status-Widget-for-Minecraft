//
//  FAQView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/16/24.
//


import SwiftUI

func getiOSFAQs() -> [FAQ] {
    #if targetEnvironment(macCatalyst)
    return [
        FAQ(question: "Can you add push notification/server analytics to the app?", answer: "These features require a server component, and would need to be a paid subscription service. This may become an option in the future."),
        FAQ(question: "Can you increase the refresh rate of the widget?", answer: "The widget is already set to the maximum allowed refresh rate. Widgets can be manually refreshed by tapping the refresh icon."),
        FAQ(question: "How do I report a bug/request a feature?", answer: "All bug reports and feature requests can be raised as an issue on the GitHub repository, linked on the previous page.")
    ]
    #else
    return [
        FAQ(question: "Can you add push notification/server analytics to the app?", answer: "These features require a server component, and would need to be a paid subscription service. This may become an option in the future."),
        FAQ(question: "My Apple Watch isn't syncing", answer: "Make sure you have iCloud enabled on one of your devices. Data is synced automatically, but may be delayed under certain conditions controlled by the OS. If after 1 minute your data isn't synced, you can restart the watch to force a resync."),
        FAQ(question: "Can you increase the refresh rate of the widget?", answer: "The widget is already set to the maximum allowed refresh rate. Widgets can be manually refreshed by tapping the refresh icon."),
        FAQ(question: "How do I report a bug/request a feature?", answer: "All bug reports and feature requests can be raised as an issue on the GitHub repository, linked on the previous page.")
    ]
    #endif
}

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQRow: View {
    let faq: FAQ
    @State private var isExpanded = false // Expanded by default

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                Text(faq.answer)
                    .font(.body)
                    .foregroundColor(.secondary) // Muted answer color
                    .padding(.vertical, 5)
            },
            label: {
                Text(faq.question)
                    .font(.title3)
                    .bold()
                    .padding(.trailing, 10)
            }
        )
    }
}

struct FAQView: View {
    let faqs: [FAQ]

    var body: some View {
        Form {
            Section {
                ForEach(faqs) { faq in
                    FAQRow(faq: faq)
                }
            }
        }
        .navigationTitle("FAQ")
        .background(Color(.systemGroupedBackground))
    }
}
