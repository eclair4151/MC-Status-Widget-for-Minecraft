//
//  ConnectivityProvider.swift
//  MCStatusWatchApp Watch App
//
//  Created by Tomer Shemesh on 8/15/23.
//

import Foundation
import WatchConnectivity

class ConnectivityProvider: NSObject, WCSessionDelegate {
        
    override init() {
        super.init()
        connect()
    }
    
    func send(message: [String:Any]) -> Void {
        guard WCSession.default.isReachable else {
            // Phone not connected. Try to directly call web api...
            return
        }
        
        // We are connectted to phone. Attempt to ask it to connect to the server on our behalf.
        // Doing this is recommended by apple to save battery life on the watch,
        // in addition to the fact that the NWConnection API is blocked on Apple watch anyway, so only a web api connection can be made directly.
        // if we fail to hear back from the phone, still try the web api anyway as a backup
        WCSession.default.sendMessage(message) { response in
            print("got response! " + response.description)
        } errorHandler: { error in
            print("Get error trying to talk to watch! ")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // code
    }
    
    func connect() {
        if WCSession.isSupported() {
           WCSession.default.delegate = self
           WCSession.default.activate()
       }
    }
}
