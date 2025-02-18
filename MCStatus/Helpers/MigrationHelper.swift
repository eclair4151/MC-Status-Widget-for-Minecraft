import Foundation

class MigrationHelper {
    static let VERSION = 1
    
    // returns nil if no migration, otherwie the current version that we just migratred to
    @MainActor static func migrationIfNeeded() -> (Int, Int)? {
        let lastVer = getLastVersion()
        
        if lastVer < VERSION {
            for i in lastVer...VERSION{
                runMigrationForVer(version: i)
            }
            
            setCurrentVersion(version: VERSION)
            
            return (lastVer,VERSION)
            
        } else {
            return nil
        }
    }
    
    @MainActor static func runMigrationForVer(version: Int) {
        switch version {
        case 0:
            migrateToV1()
            
        default:
            return
        }
    }
    
    @MainActor static func migrateToV1() {
        RealmDbMigrationHelper.shared.migrateServersToSwiftData()
    }
    
    static  func getLastVersion() -> Int {
        UserDefaults.standard.integer(forKey: "appVer")
    }
    
    static func setCurrentVersion(version: Int) {
        UserDefaults.standard.set(version, forKey: "appVer")
    }
}
