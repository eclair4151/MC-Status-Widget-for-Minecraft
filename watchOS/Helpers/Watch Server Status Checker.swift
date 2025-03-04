import Foundation
import MCStatsDataLayer
import WatchConnectivity

final class WatchServerStatusChecker {
    var responseListener: ((UUID, ServerStatus) -> Void)?
    let connectivityProvider = ConnectivityProvider()
    var expectedResponseBatches: Set<ExpectedResultBatch> = Set()
    
    init() {
        self.connectivityProvider.responseListener = { message in
            // recevied message from phone. Parse and remove from expected results, before passing on to listener
            guard let (serverID, status) = self.parseWatchResponse(message) else {
                return
            }
            
            print("Received response from phone!")
            
            for batch in self.expectedResponseBatches {
                batch.expectedResults.removeValue(forKey: serverID)
            }
            
            self.responseListener?(serverID, status)
        }
    }
    
    func checkServerAsync(_ server: SavedMinecraftServer) async -> ServerStatus {
        var didCallContinuation = false
        
        return await withCheckedContinuation { continuation in
            responseListener = {
                if !didCallContinuation {
                    didCallContinuation = true
                    continuation.resume(returning: $1)
                }
            }
            
            checkServers([server])
        }
    }
    
    func checkServers(_ servers: [SavedMinecraftServer]) {
        print("Watch is going to ask for server status from phone")
        
        let serverBatch = servers.reduce(into: [UUID: SavedMinecraftServer]()) {
            $0[$1.id] = $1
        }
        
        let expectedBatch = ExpectedResultBatch(expectedResults: serverBatch)
        
        expectedResponseBatches.insert(expectedBatch)
        
        Task {
            do {
                var connectiveStateCounter = 0
                // first wait up to 1s for the phone to become available
                while (!WCSession.default.isReachable || connectivityProvider.connectionState != .activated) && connectiveStateCounter < 4 {
                    connectiveStateCounter += 1
                    try await Task.sleep(nanoseconds: UInt64(0.25 * Double(NSEC_PER_SEC)))
                }
                
                // only bother trying to connect via phone is it says it is reachable
                if WCSession.default.isReachable {
                    try checkServersViaPhone(servers)
                    // wait 8 seconds, and check if we need to backup for any of the pending servers
                    try await Task.sleep(nanoseconds: UInt64(8) * NSEC_PER_SEC)
                }
                
            } catch let error {
                print("Failed to check servers via phone:", error.localizedDescription)
            }
            
            // after timeout, anything left in the batch needs to be checked via the backup web API
            expectedBatch.expectedResults.forEach { id, server in
                // start new async task for each request to go in parrallel
                Task {
                    let status = await checkServerViaWeb(server)
                    self.responseListener?(id, status)
                }
            }
            
            expectedResponseBatches.remove(expectedBatch)
        }
    }
    
    private func parseWatchResponse(_ message: [String: Any]) -> (UUID, ServerStatus)? {
        guard
            let responseString = message["response"] as? String,
            let jsonData = responseString.data(using: .utf8)
        else {
            return nil
        }
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(WatchResponseMessage.self, from: jsonData)
            return (response.id, response.status)
        } catch {
            print("Error decoding", error.localizedDescription)
            return nil
        }
    }
    
    private func checkServersViaPhone(_ servers: [SavedMinecraftServer]) throws {
        let messageRequest = WatchRequestMessage()
        messageRequest.servers = servers
        
        let encoder = JSONEncoder()
        
        let jsonData = try encoder.encode(messageRequest)
        
        // Convert the JSON data to a string
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw ServerStatusCheckerError.StatusUnparsable
        }
        
        let payload = ["request": jsonString]
        
        print("sending request...")
        try connectivityProvider.send(payload)
        
        print("try to send request...")
    }
    
    // if we are calling third party do it individually so we can show the responses as they come in
    private func checkServerViaWeb(_ server: SavedMinecraftServer) async -> ServerStatus {
        do {
            print("CALLING BACKUP SERVER")
            
            let res = try await WebServerStatusChecker.checkServer(
                url: server.serverUrl,
                port: server.serverPort,
                type: server.serverType,
                config: nil
            )
            
            res.source = Source.ThirdParty
            
            print("Got result from third part. Returning...")
            
            return res
        } catch {
            // If not able to connect to the MC server directly, nor able to connect to the 3rd party server
            // We arent online at all most likely
            // Status is unknown (default value)
            print("ERROR DIRECT CONNECTING TO BACKUP SERVER: phone most likely not connected at all", error.localizedDescription)
            return ServerStatus()
        }
    }
}
