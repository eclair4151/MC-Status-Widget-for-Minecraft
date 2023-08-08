//
//  ServerStatusChecker.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 8/6/23.
//

import Foundation

class ServerStatusChecker {
    static func checkServer(server:SavedMinecraftServer) async -> ServerStatus {
        print("starting server check for: " + server.serverUrl)
        // STEP 1 if we have SRV values, check that server.
        // only Java servers support SRV records
        if UserDefaultHelper.SRVEnabled() && server.serverType == .Java && !server.srvServerUrl.isEmpty && server.srvServerPort != -1 {
            do {
                print("CHECKING SERVER FROM CACHED SRV: " + server.srvServerUrl)
                return try await DirectServerStatusChecker.checkServer(serverUrl: server.srvServerUrl, serverPort: server.srvServerPort, serverType: server.serverType)
            } catch {
                // something when horribly wrong. Move to next step
                print("ERROR CONNECTING TO CACHED SRV: " + error.localizedDescription)
            }
        }
        
    
        // STEP 2 if the direct provided url is different that the SRV record, attempt to connect using that directly.
        // ALSO THIS IS WHEN WE CONNECT TO BEDROCK SINCE THEY DONT HAVE SRV
        if server.serverType == .Bedrock || server.serverUrl != server.srvServerUrl || server.serverPort != server.srvServerPort {
            do {
                print("CONNECTING TO SERVER DIRECTLY (IGNORING SRV)")
                return try await DirectServerStatusChecker.checkServer(serverUrl: server.serverUrl, serverPort: server.serverPort, serverType: server.serverType)
            } catch {
                // something when horribly wrong. Move to next step
                print("ERROR DIRECT CONNECTING TO MANUAL SERVER + PORT: " + error.localizedDescription)
            }
        }
        
        
        // STEP 3 if we still could not connect, refresh the SRV if its a java server, maybe there is an update
        // if we recevied updated values from previous SRV, attempt ot connect using that
        if UserDefaultHelper.SRVEnabled() && server.serverType == .Java {
            if let srvRecord = await SRVResolver.lookupMinecraftSRVRecord(serverURL: server.serverUrl), (srvRecord.0 != server.srvServerUrl || srvRecord.1 != server.srvServerPort) {
                //got updated SRV info, updated it and try to connect.
                server.srvServerUrl = srvRecord.0
                server.srvServerPort = srvRecord.1
                // we need to save it in swift data here.
                print("FOUND NEW SRV RECORD FROM DNS! CHECKING SERVER AT: " + server.srvServerUrl)

                do {
                    return try await DirectServerStatusChecker.checkServer(serverUrl: server.srvServerUrl, serverPort: server.srvServerPort, serverType: server.serverType)
                } catch {
                    // something when horribly wrong. Move to next step
                    print("ERROR CONNECTING TO NEW SRV: " + error.localizedDescription)
                }
            }
        }
        
        
        // STEP 4 if all else fails, ask 3rd party web server for info.
        // if we hear back from the 3rd party server, and they also say the server is offline, we can agree its offline
        do {
            print("CALLING BACKUP SERVER")
            return try await WebServerStatusChecker.checkServer(serverUrl: server.serverUrl, serverPort: server.serverPort, serverType: server.serverType)
        } catch {
            // if we arent able to connect to the minecraft server directly, nor are we able to connect to the 3rd party server
            // we arent online at all most likley. status is unknown (default value)
            print("ERROR DIRECT CONNECTING TO BACKUP SERVER: phone most likley not connected at all." + error.localizedDescription)
            return ServerStatus()
        }
    }
}



//            let res = await SwiftyPing.pingServer(serverUrl: serverURL)
//            print("got res: " + String(res.duration))

let servers = ["buzz.manacube.com",
               "play.MysticMC.co",
               "buzz.netherite.gg",
               "join.wildwoodsmp.com",
               "buzz.bosscraft.net",
               "buzz.pixelblockmc.com",
               "Play.SiphonMC.net",
               "mc.advancius.net",
               "mc.thecavern.net",
               "bedrock.pika.host",
               "bedrock.jartex.fun",
               "bedrock.akumamc.net",
               "buzz.havoc.games",
               "bedrock.opblocks.com",
               "play.applemc.fun",
               "buzz.cosmosmc.org",
               "buzz.catcraft.net",
               "play.blossomcraft.org",
               "join.wildwoodsmp.com",
               "buzz.netherite.gg",
               "buzz.zedarmc.com",
               "plateousmp.net",
               "buzz.semisurvivalcraft.com",
               "Play.MinePower.Org",
               "play.vanillarealms.com",
            ]

func testCall() {
    for serverURL in servers {
    let statusCheckerTask = Task {
            let server = SavedMinecraftServer()
            server.serverType = .Bedrock
            server.serverPort = 19132
            server.serverUrl = serverURL
//            server.serverPort = 25565
            let status = await ServerStatusChecker.checkServer(server: server)
            print("👉: " + status.version + "  -   " + status.status.rawValue)
        }
    }
}
