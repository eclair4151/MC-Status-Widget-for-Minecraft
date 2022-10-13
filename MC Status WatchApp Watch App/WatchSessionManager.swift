//
//  WatchSessionManager.swift
//  MC Status WatchApp Watch App
//
//  Created by Tomer Shemesh on 10/13/22.
//  Copyright © 2022 ShemeshApps. All rights reserved.
//

import Foundation
import WatchConnectivity


class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
  
    
    private let session = WCSession.default
    @Published var appData = "Minecraft Status Watch App"

    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(session.applicationContext)
        print("here")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async{
            //WatchDefaultsManager.importInfo(data: applicationContext)
            //self.appData.refresh()
            if let serverData = applicationContext["serverData"] as? String{
                self.appData = serverData
                print("\(serverData)")
            }
        }
    }
                                                                          
}


