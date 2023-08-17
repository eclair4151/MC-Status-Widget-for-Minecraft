//
//  ConnectivityProvider.swift
//  MCStatusWatchApp Watch App
//
//  Created by Tomer Shemesh on 8/15/23.
//

import Foundation
import WatchConnectivity

class ConnectivityProvider: NSObject, WCSessionDelegate {
    
    private let session: WCSession
    
    override init() {
        self.session = WCSession.default
        super.init()
        self.session.delegate = self
    }
    
    func send(message: [String:Any]) -> Void {
        session.sendMessage(message) { response in
            
        } errorHandler: { error in
            
        }

    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // code
    }
    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        
//    }
    
    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
       
        session.activate()
    }
}
