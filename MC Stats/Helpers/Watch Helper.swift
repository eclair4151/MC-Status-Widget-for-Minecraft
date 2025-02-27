import WatchConnectivity
import SwiftData
import MCStatsDataLayer

class WatchHelper: NSObject, WCSessionDelegate {
    override init() {
        super.init()
        connect()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("watch session changed state:", String(activationState.rawValue))
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("watch session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("watch session deactivated")
    }
    
    func handleWatchMessage(message: [String: Any], session: WCSession) {
        let decoder = JSONDecoder()
        
        // I've done the lazy thing and hard coded the logic directly in here
        // Should be moved to a helper func at some point
        guard
            let requestString = message["request"] as? String,
            let jsonData = requestString.data(using: .utf8),
            let request = try? decoder.decode(WatchRequestMessage.self, from: jsonData)
        else {
            // unknown input? return nothing
            print("Error parsing watch request")
            return
        }
        
        // for each server, get response, and send responses back as we receive them to the watch
        // we start a new task for each server to let them run in parrallel
        for server in request.servers {
            Task {
                let result = await ServerStatusChecker.checkServer(server)
                let messageResponse = WatchResponseMessage(id: server.id, status: result)
                
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(messageResponse)
                
                // Convert the JSON data to a string
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    throw ServerStatusCheckerError.StatusUnparsable
                }
                
                let payload = ["response": jsonString]
                
                print("SENDING STATUS RESPONSE TO WATCH")
                
                WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                    print("ERROR SENDING STATUS RESPONSE TO WATCH:", error.localizedDescription)
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("We've been waken from the background, and have been asked for data from the watch!")
        
        // initilize model container since sometimes it's not ready yet??
        // https://developer.apple.com/forums/thread/734212
        let container = SwiftDataHelper.getModelContainter()
        
        handleWatchMessage(message: message, session: session)
        
        print("container:" + container.schema.debugDescription)
    }
    
    func connect() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
}
