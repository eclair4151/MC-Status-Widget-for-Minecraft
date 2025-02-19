import Foundation

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    
    init(_ question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}
