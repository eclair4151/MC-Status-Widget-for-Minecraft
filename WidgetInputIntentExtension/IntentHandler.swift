//
//  IntentHandler.swift
//  WidgetInputIntentExtension
//
//  Created by Tomer on 1/27/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Intents
import RealmSwift

class IntentHandler: INExtension, ServerSelectIntentHandling, ServerSelectNoThemeIntentHandling {

    
    func resolveTheme(for intent: ServerSelectIntent, with completion: @escaping (ThemeIntentTypeResolutionResult) -> Void) {
        if let theme = intent.Theme {
            completion(ThemeIntentTypeResolutionResult.success(with: theme))
        }
    }
    
    func provideThemeOptionsCollection(for intent: ServerSelectIntent, with completion: @escaping (INObjectCollection<ThemeIntentType>?, Error?) -> Void) {
        
        let themeOptions: [ThemeIntentType] = Theme.allCases.map { theme in
            ThemeIntentType(identifier: theme.rawValue, display: theme.rawValue)
        }
        
        let collection = INObjectCollection(items: themeOptions)
        completion(collection, nil)
    }
    
    func defaultTheme(for intent: ServerSelectIntent) -> ThemeIntentType? {
        let theme = Theme.auto
        return ThemeIntentType(identifier: theme.rawValue, display: theme.rawValue)
    }
        

    
    func getProviderServerOptions() -> INObjectCollection<ServerIntentType> {
        let realm = initializeRealmDb()
        let servers = realm.objects(SavedServer.self).sorted(byKeyPath: "order")
        
        let serverOptions: [ServerIntentType] = servers.map { server in
            let serverObj = ServerIntentType(
                identifier: server.id, display: server.name
            )
            return serverObj
        }

       return INObjectCollection(items: serverOptions)
    }
    
    
    
    // for homescreen widgets
    func resolveServer(for intent: ServerSelectIntent, with completion: @escaping (ServerIntentTypeResolutionResult) -> Void) {
        if let server = intent.Server {
            completion(ServerIntentTypeResolutionResult.success(with: server))
        }
    }
    
    
    func provideServerOptionsCollection(for intent: ServerSelectIntent, with completion: @escaping (INObjectCollection<ServerIntentType>?, Error?) -> Void) {
        completion(getProviderServerOptions(), nil)
    }
    
     
    // for lock screen widgets
    func resolveServer(for intent: ServerSelectNoThemeIntent, with completion: @escaping (ServerIntentTypeResolutionResult) -> Void) {
        if let server = intent.Server {
            completion(ServerIntentTypeResolutionResult.success(with: server))
        }
    }
    
    func provideServerOptionsCollection(for intent: ServerSelectNoThemeIntent, with completion: @escaping (INObjectCollection<ServerIntentType>?, Error?) -> Void) {
        completion(getProviderServerOptions(), nil)

    }
    
    
    

    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        return self
    }
    
}
