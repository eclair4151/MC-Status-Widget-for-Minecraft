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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("we've been waken from the background, and have been asked for data from the watch!!")
        let responseData: [String: Any] = ["responseKey": "responseValue"]
        
        print("sending response to watch!")
        replyHandler(responseData)
    }
    
    func connect() {
        if WCSession.isSupported() {
               WCSession.default.delegate = self
               WCSession.default.activate()
           }
    }
}
