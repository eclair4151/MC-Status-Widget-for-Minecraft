import SwiftUI

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: LocalizedStringKey
    
    init(_ question: String, answer: LocalizedStringKey) {
        self.question = question
        self.answer = answer
    }
}
