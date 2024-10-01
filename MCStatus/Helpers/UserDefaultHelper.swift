//
//  UserDefaultHelper.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 8/6/23.
//

import Foundation

class UserDefaultHelper {
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
    
    static func SRVEnabled() -> Bool {
        return true
    }
    
    static func iCloudEnabled() -> Bool {
        return true
    }
    
    static func showUsersOnHomesreen() -> Bool {
        return true
    }
    
}



