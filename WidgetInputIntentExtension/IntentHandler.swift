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
        
    func resolveServer(for intent: ServerSelectIntent, with completion: @escaping (ServerIntentTypeResolutionResult) -> Void) {
        if let server = intent.Server {
            completion(ServerIntentTypeResolutionResult.success(with: server))
        }
    }
    
    func provideServerOptionsCollection(for intent: ServerSelectIntent, with completion: @escaping (INObjectCollection<ServerIntentType>?, Error?) -> Void) {
        
        let realm = initializeRealmDb()
        let servers = realm.objects(SavedServer.self).sorted(byKeyPath: "order")
        
        let serverOptions: [ServerIntentType] = servers.map { server in
            let serverObj = ServerIntentType(
                identifier: server.id, display: server.name
            )
            serverObj.serverName = server.name
            return serverObj
        }

        let collection = INObjectCollection(items: serverOptions)

        completion(collection, nil)
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        return self
    }
    
}
