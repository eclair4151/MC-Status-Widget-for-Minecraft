//
//  MigrationHelper.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/7/24.
//

import Foundation
import RealmSwift

let VERSION = 1

func migrationIfNeeded() {
    let lastVer = getLastVersion()
    if lastVer < VERSION {
        for i in lastVer...VERSION{
            runMigrationForVer(version: i)
        }
        setCurrentVersion(version: VERSION)
    }
}


func runMigrationForVer(version: Int) {
    switch version {
    case 0:
        migrateToV1()
    default:
        return
    }
}

func migrateToV1() {

}


func getLastVersion() -> Int {
    return  UserDefaults.standard.integer(forKey: "appVer")
}

func setCurrentVersion(version: Int) {
    UserDefaults.standard.set(version, forKey: "appVer")
}
