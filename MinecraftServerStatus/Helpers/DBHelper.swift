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
    
    Realm.Configuration.defaultConfiguration = Realm.Configuration (
        fileURL: sharedRealmURL,
        schemaVersion: 2,
        migrationBlock: { migration, oldSchemaVersion in
            //nothing to do here since we not altering any data
    })
    
    return try! Realm()
}


func dumpDBtoPrefs() {
    
    let realm = initializeRealmDb()
    let servers = Array(realm.objects(SavedServer.self).sorted(byKeyPath: "order") as Results<SavedServer>)
    let jsonEncoder = JSONEncoder()
    let jsonDataOpt = try? jsonEncoder.encode(servers)
    
    if let jsonData = jsonDataOpt {
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        let defaults = UserDefaults.standard
        defaults.set(json, forKey: "serverDump")

    }
}


func loadServerDump() {
    let defaults = UserDefaults.standard
    let jsonString = defaults.string(forKey: "serverDump") ?? ""
    
    let jsonDecoder = JSONDecoder()
    let servers = try? jsonDecoder.decode([SavedServer].self, from: jsonString.data(using: .utf8)!)
    print(jsonString)
}
