import Foundation

class MigrationHelper {
    static let VERSION = 1
    
    // returns nil if no migration, otherwie the current version that we just migratred to
    @MainActor static func migrationIfNeeded() -> (Int, Int)? {
        let lastVer = getLastVersion()
        
        if lastVer < VERSION {
            for i in lastVer...VERSION{
                runMigrationForVer(i)
            }
            
            setCurrentVersion(VERSION)
            
            return (lastVer, VERSION)
            
        } else {
            return nil
        }
    }
    
    @MainActor static func runMigrationForVer(_ version: Int) {
        switch version {
        default:
            return
        }
    }
    
    static func getLastVersion() -> Int {
        UserDefaults.standard.integer(forKey: "appVer")
    }
    
    static func setCurrentVersion(_ version: Int) {
        UserDefaults.standard.set(version, forKey: "appVer")
    }
}
