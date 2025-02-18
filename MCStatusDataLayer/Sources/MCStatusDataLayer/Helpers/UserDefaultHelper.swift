import Foundation

class UserDefaultHelper {
    // Define the possible keys as an enum
    enum Key: String {
        case iCloudEnabled,
             showUsersOnHomesreen,
             sortUsersByName
        // Add more keys here as needed
    }
    
    // Singleton instance for easy access
    static let shared = UserDefaultHelper()
    
    // Prevents external instantiation
    private init() {
        
    }
    
    // Func to set a boolean value
    func set(_ value: Bool, for key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    // Func to get a boolean value, with a default if not set
    func get(for key: Key, defaultValue: Bool = false) -> Bool {
        UserDefaults.standard.object(forKey: key.rawValue) as? Bool ?? defaultValue
    }
}

//    static var logLines: [String] = []
//
//    static func logLine(ident: String) {
//        let defaults = UserDefaults.standard
//
//        let pid = ProcessInfo().processIdentifier
//        let time = Date().timeIntervalSince1970
//
//        var prev = getLogLines()
//        let log = String(pid) + ":" + String(time) + ": appEvent - " + ident
//        print("!👉" + log)
//        prev.append(log)
//        defaults.set(prev, forKey: "appLog")
//    }
//
//    static func getLogLines() -> [String] {
//        let defaults = UserDefaults.standard
//        return defaults.stringArray(forKey: "appLog") ?? []
//    }
