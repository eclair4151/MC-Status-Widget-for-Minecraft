import SwiftUI

struct FAQRow: View {
    private let faq: FAQ
    
    init(_ faq: FAQ) {
        self.faq = faq
    }
    
    // Expanded by default
    @State private var isExpanded = false
    
    var body: some View {
#if os(tvOS)
        VStack(alignment: .leading) {
            Text(faq.answer)
                .secondary()
                .padding(.vertical, 5)
            
            Text(faq.question)
                .title3(.bold)
                .padding(.trailing, 10)
        }
#else
        DisclosureGroup(isExpanded: $isExpanded) {
            Text(faq.answer)
                .secondary()
                .padding(.vertical, 5)
        } label: {
            Text(faq.question)
                .title3(.bold)
                .padding(.trailing, 10)
        }
#endif
    }
}
