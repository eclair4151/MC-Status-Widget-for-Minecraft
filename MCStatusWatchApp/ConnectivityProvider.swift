//
//  ConnectivityProvider.swift
//  MCStatusWatchApp Watch App
//
//  Created by Tomer Shemesh on 8/15/23.
//

import Foundation
import WatchConnectivity


enum WatchConnectivityError: Error {
    case DeviceNotConnected
    case ResponseParseError
}

class ConnectivityProvider: NSObject, WCSessionDelegate {
        
    var responseListener: (([String:Any]) -> Void)?
    
    override init() {
        super.init()
        self.connect()
    }
    
    // converted code to comminucate with iPhone as async/Await
    // send a message to the phone. error throw if one is encountered
    func send(message: [String:Any]) throws {
        guard WCSession.default.isReachable else {
            // Phone not connected. throw error
            throw WatchConnectivityError.DeviceNotConnected
        }
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Get error trying to talk to phone: " + error.localizedDescription)
        }
    }
    
    // this should be where we recived the status from the iPhone after requesting it
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        responseListener?(message)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activationState: " + String(activationState.rawValue))
    }
    
    func connect() {
        if WCSession.isSupported() {
           WCSession.default.delegate = self
           WCSession.default.activate()
       }
    }
}