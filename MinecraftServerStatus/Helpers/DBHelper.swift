//
//  DBHelper.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 2/7/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import RealmSwift

// Return a realm instance, and always make sure the correct defaults are set
func initializeRealmDb() -> Realm {
    let sharedDirectory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.shemeshapps.MinecraftServerStatus")! as URL
    let sharedRealmURL = sharedDirectory.appendingPathComponent("db.realm")
    Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: sharedRealmURL)
    return try! Realm()
}
