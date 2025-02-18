import Foundation
import WatchConnectivity

enum WatchConnectivityError: Error {
    case DeviceNotConnected, ResponseParseError
}

class ConnectivityProvider: NSObject, WCSessionDelegate {
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
#endif
    
    var responseListener: (([String:Any]) -> Void)?
    var connectionState: WCSessionActivationState = .inactive
    
    override init() {
        super.init()
        self.connect()
    }
    
    // converted code to comminucate with iPhone as async/Await
    // send a message to the phone. error throw if one is encountered
    func send(message: [String:Any]) throws {
        print("Checking if phone is connected to watch...")
        
        guard WCSession.default.isReachable else {
            // Phone not connected. throw error
            print("Phone is not connected..")
            throw WatchConnectivityError.DeviceNotConnected
        }
        
        print("Phone seems to be connected. Sending message to phone...")
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Get error trying to talk to phone: " + error.localizedDescription)
        }
    }
    
    // this should be where we recived the status from the iPhone after requesting it
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        responseListener?(message)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activationState: " + String(activationState.rawValue))
        connectionState = activationState
    }
    
    func connect() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
}
