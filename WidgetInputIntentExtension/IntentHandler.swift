//
//  IntentHandler.swift
//  WidgetInputIntentExtension
//
//  Created by Tomer on 1/27/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Intents
import RealmSwift

class IntentHandler: INExtension, ServerSelectIntentHandling {
    
    let realm: Realm
    
    override init() {
        let sharedDirectory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.shemeshapps.MinecraftServerStatus")! as URL
        let sharedRealmURL = sharedDirectory.appendingPathComponent("db.realm")
        Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: sharedRealmURL)
        
        self.realm = try! Realm()
        super.init()
    }
    
    func resolveServer(for intent: ServerSelectIntent, with completion: @escaping (ServerIntentTypeResolutionResult) -> Void) {
        if let server = intent.Server {
            completion(ServerIntentTypeResolutionResult.success(with: server))
        }
    }
    
    func provideServerOptionsCollection(for intent: ServerSelectIntent, with completion: @escaping (INObjectCollection<ServerIntentType>?, Error?) -> Void) {
        
        let servers = self.realm.objects(SavedServer.self).sorted(byKeyPath: "order")


        // Iterate the available characters, creating
        // a GameCharacter for each one.
        let serverOptions: [ServerIntentType] = servers.map { server in
            let serverObj = ServerIntentType(
                identifier: server.id, display: server.name
            )
            serverObj.serverName = server.name
            return serverObj
        }

        
//        var serverOptions: [ServerIntentType] = []
//        if (servers.count > 0) {
//            serverOptions.append(ServerIntentType(
//                                identifier: "server.id", display: "server.name"
//                            ))
//            serverOptions[0].serverName = "terstttt"
//        }

        // Create a collection with the array of characters.
        let collection = INObjectCollection(items: serverOptions)

        // Call the completion handler, passing the collection.
        completion(collection, nil)
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
