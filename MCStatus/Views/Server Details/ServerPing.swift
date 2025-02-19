import Foundation

struct ServerPing: Identifiable {
    let id = UUID()
    let ping: Int
    let date: Date
    
    init(_ ping: Int, date: Date = Date()) {
        self.ping = ping
        self.date = date
    }
}
