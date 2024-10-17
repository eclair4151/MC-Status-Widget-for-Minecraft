//
//  MigrationHelper.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/7/24.
//

import Foundation
import MCStatusDataLayer

class MigrationHelper {
    
    static let VERSION = 1
    
    @MainActor static func migrationIfNeeded() {
        let lastVer = getLastVersion()
        if lastVer < VERSION {
            for i in lastVer...VERSION{
                runMigrationForVer(version: i)
            }
            setCurrentVersion(version: VERSION)
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
        RealmDbMigrationHelper().migrateServersToSwiftData()
    }
    
    
    static  func getLastVersion() -> Int {
        return  UserDefaults.standard.integer(forKey: "appVer")
    }
    
    static func setCurrentVersion(version: Int) {
        UserDefaults.standard.set(version, forKey: "appVer")
    }
}



