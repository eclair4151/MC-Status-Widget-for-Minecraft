//
//  SavedServer.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 6/2/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import Foundation
import RealmSwift

//server model for the database
public class SavedServer: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var serverUrl = ""
    @objc dynamic var serverIcon = ""
    @objc dynamic var order = 100
    @objc dynamic var showInWidget = false

}
