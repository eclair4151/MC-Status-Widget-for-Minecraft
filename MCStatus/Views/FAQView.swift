//
//  FAQView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/16/24.
//


import SwiftUI

func getiOSFAQs() -> [FAQ] {
    return [
        FAQ(question: "What is SwiftUI?", answer: "SwiftUI is a modern way to declare user interfaces for any Apple platform."),
        FAQ(question: "How does SwiftUI work?", answer: "SwiftUI uses a declarative syntax, so you can simply state what your UI should do."),
        FAQ(question: "Can I use SwiftUI with UIKit?", answer: "Yes, you can integrate SwiftUI with UIKit in your existing apps.")
    ]
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
