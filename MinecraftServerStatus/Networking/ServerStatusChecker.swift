//
//  ServerStatusChecker.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 8/6/23.
//

import Foundation
class ServerStatusChecker {
    static func checkServer(server:SavedMinecraftServer) async -> ServerStatus {
        print("starting server check for: " + server.serverUrl)
        // STEP 1 if we have SRV values, check that server.
        // only Java servers support SRV records
        if server.serverType == .Java && !server.srvServerUrl.isEmpty && server.srvServerPort != -1 {
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
        if server.serverType == .Java {
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
        do {
            print("CALLING BACKUP SERVER")
            return try await WebServerStatusChecker.checkServer(serverUrl: server.serverUrl, serverPort: server.serverPort, serverType: server.serverType)
        } catch {
            // we arent online at all most likley. status is unknown (default value)
            print("ERROR DIRECT CONNECTING TO BACKUP SERVER: phone most likley not connected at all." + error.localizedDescription)
            return ServerStatus()
        }
    }
}



//            let res = await SwiftyPing.pingServer(serverUrl: serverURL)
//            print("got res: " + String(res.duration))

let servers = [
//    "mslc.mc-complex.com",
//    "tomershemesh.me",
//    "hodor",
//    "mcslp.pika.host",
//    "msl.pixelmonrealms.com",
//    "mcslp.jartex.fun",
//    "play.penguin.gg",
//    "akumamc.net",
//    "play.neocubest.com",
//    "lobby.havoc.games",
//    "fun.opblocks.com",
//    "play.anubismc.com",
//    "play.smashmc.co",
//    "msl.applemc.fun",
//    "mcsl.astrocraft.org",
//    "msl.ultimis.net",
//    "mcsl.oneblockmc.com",
//    "play.extremecraft.net",
//    "mc.gamster.org",
//    "play.pokesaga.org",
//    "mc.lotc.co",
//    "plateousmp.net",
//    "fun.oplegends.com",
//    "mcsl.zedarmc.com",
//    "play.vulengate.com",
//    "Play.PokeFind.co",
//    "play.underblock.gg",
//    "skyblock.net",
//    "play.fishonmc.net",
//    "sl.minecadia.com",
//    "join.mccentral.org",
//    "fly.join-mineland.online",
//    "Herobrine.org",
    "mcsl.vortexnetwork.net",
    "msl.simplesurvival.gg",
    "msl.pokehub.org",
    "ms.Minerival.org",
    "mcsl.lemoncloud.net",
    "budgie.network",
    "play.boxpvp.net",
    "mcsl.wildprison.net",
    "play.strongcraft.org",
    "mcsl.gtm.network",
    "go.mineberry.org",
    "minecraftonline.com",
    "mc.advancius.net",
    "play.alttd.com",
    "mc.mcs.gg",
    "armamc.com",
    "LeoneMC.net",
    "play.cubecraft.net",
    "play.maritime.gg",
    "play.mc-speed.com",
    "play.mineheart.net",
    "mcsl.semisurvivalcraft.com",
    "msl.ccnetmc.com",
    "mcsl.savermc.net",
    "Play.Performium.co",
    "msl.mc-blaze.com",
    "join.ventureland.net",
    "msl.serb-craft.com"
            ]

func testCall() {
    let statusCheckerTask = Task {
        for serverURL in servers {
            let server = SavedMinecraftServer()
//            server.serverType = .Bedrock
//            server.serverPort = 19132
            server.serverUrl = serverURL
            server.serverPort = 25565
            let status = await ServerStatusChecker.checkServer(server: server)
            print("👉: " + status.version + "  -   " + status.status.rawValue)
        }
    }
   
}
