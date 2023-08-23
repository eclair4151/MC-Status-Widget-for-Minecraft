//
//  WatchHelper.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/18/23.
//
import WatchConnectivity
import Foundation

class WatchHelper: NSObject, WCSessionDelegate {
    override init() {
        super.init()
        connect()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("watch session changed state: " + String(activationState.rawValue))
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("watch session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("watch session deactivated")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("we've been waken from the background, and have been asked for data from the watch!")
        
        // i've done the lazy thing and hard coded the logic directly in here. Should be moved to a helper function at some point.
        guard let watchRequest = message["request"] as? WatchRequestMessage else {
            // unknown input? return nothing
            return
        }
        
        // for each server, get response, and send responses back as we receive them to the watch
        // we start a new task for each server to let them run in parrallel
        for server in watchRequest.servers {
            Task {
                let result = await ServerStatusChecker.checkServer(server: server)
                let messageResponse = WatchResponseMessage(id: server.id, status:result)
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(messageResponse)
                
                // Convert the JSON data to a string
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    throw ServerStatusCheckerError.StatusUnparsable
                }
                
                let payload = ["response":jsonString]
               
                session.sendMessage(payload) { error in
                    print("ERROR SENDING STATUS RESPONSE TO WATCH: " + error.debugDescription)
                }
            }
        }
    }
    
    func connect() {
        if WCSession.isSupported() {
               WCSession.default.delegate = self
               WCSession.default.activate()
           }
    }
}
