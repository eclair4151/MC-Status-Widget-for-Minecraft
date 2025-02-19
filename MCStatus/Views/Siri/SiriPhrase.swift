import Foundation

struct SiriPhrase: Identifiable {
    let id = UUID()
    let phrase: String
    
    init(_ phrase: String) {
        self.phrase = phrase
    }
}
