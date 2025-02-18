import SwiftUI

struct SiriGuidePhrase: View {
    private let phrase: SiriPhrase
    
    init(_ phrase: SiriPhrase) {
        self.phrase = phrase
    }
    
    var body: some View {
        HStack {
            Image(systemName: "mic.fill")
                .foregroundColor(.blue)
                .imageScale(.large)
                .padding(.trailing, 5)
            
            Text("\"\(phrase.phrase)\"")
                .subheadline()
                .foregroundColor(.primary)
        }
        .padding(.vertical, 5)
    }
}
