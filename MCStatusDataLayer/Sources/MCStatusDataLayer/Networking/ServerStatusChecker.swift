import Foundation

public class ServerStatusChecker {
    public static func checkServer(server:SavedMinecraftServer, config: ServerCheckerConfig? = nil) async -> ServerStatus {
        //        if server.serverType == .Bedrock {
        //            do {
        //                //aritifical delay for testing
        //                try await Task.sleep(nanoseconds: UInt64(1) * NSEC_PER_SEC)
        //            } catch {}
        //        }
        
        let forceRefeshSrv = config?.forceSRVRefresh ?? false
        
        // first check if we need to refresh the srv
        if forceRefeshSrv {
            if let srvRecord = await SRVResolver.lookupMinecraftSRVRecord(serverURL: server.serverUrl), (srvRecord.0 != server.srvServerUrl || srvRecord.1 != server.srvServerPort) {
                //got updated SRV info, updated it and try to connect.
                // update on main thread to avoid crashing?
                await MainActor.run {
                    server.srvServerUrl = srvRecord.0
                    server.srvServerPort = srvRecord.1
                }
            }
        }
        
        print("starting server check for: " + server.serverUrl)
        
        // STEP 1 if we have SRV values, check that server.
        // only Java servers support SRV records
        if  server.serverType == .Java && !server.srvServerUrl.isEmpty && server.srvServerPort != 0 {
            do {
                print("CHECKING SERVER FROM CACHED SRV: " + server.srvServerUrl)
                let res = try await DirectServerStatusChecker.checkServer(serverUrl: server.srvServerUrl, serverPort: server.srvServerPort, serverType: server.serverType, config: config)
                res.source = .CachedSRV
                return res
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
                
                let res = try await DirectServerStatusChecker.checkServer(serverUrl: server.serverUrl, serverPort: server.serverPort, serverType: server.serverType, config: config)
                res.source = .Direct
                
                return res
            } catch {
                // something when horribly wrong. Move to next step
                print("ERROR DIRECT CONNECTING TO MANUAL SERVER + PORT: " + error.localizedDescription)
            }
        }
        
        // STEP 3 first check if we already tried ot refresh the SRV based on previous forcing.
        // if not, and we still could not connect, refresh the SRV if its a java server, maybe there is an update
        // if we recevied updated values from previous SRV, attempt ot connect using that
        if !forceRefeshSrv && server.serverType == .Java {
            if let srvRecord = await SRVResolver.lookupMinecraftSRVRecord(serverURL: server.serverUrl), (srvRecord.0 != server.srvServerUrl || srvRecord.1 != server.srvServerPort) {
                //got updated SRV info, updated it and try to connect.
                // update on main thread to avoid crashing?
                await MainActor.run {
                    server.srvServerUrl = srvRecord.0
                    server.srvServerPort = srvRecord.1
                }
                
                // we need to save it in swift data here.
                print("FOUND NEW SRV RECORD FROM DNS! CHECKING SERVER AT: " + server.srvServerUrl)
                
                do {
                    let res = try await DirectServerStatusChecker.checkServer(
                        serverUrl: server.srvServerUrl,
                        serverPort: server.srvServerPort,
                        serverType: server.serverType,
                        config: config
                    )
                    
                    res.source = .UpdatedSRV
                    return res
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
            
            let res = try await WebServerStatusChecker.checkServer(serverUrl: server.serverUrl, serverPort: server.serverPort, serverType: server.serverType, config: config)
            res.source = .ThirdParty
            print("Got result from third part. Returning...")
            
            return res
        } catch {
            // if we arent able to connect to the minecraft server directly, nor are we able to connect to the 3rd party server
            // we arent online at all most likley. status is unknown (default value)
            print("ERROR DIRECT CONNECTING TO BACKUP SERVER: phone most likley not connected at all." + error.localizedDescription)
            return ServerStatus()
        }
    }
}

public struct ServerCheckerConfig {
    public var sortUsers = false
    public var forceSRVRefresh = false
    
    public init(sortUsers: Bool = false, forceSRVRefresh: Bool = false) {
        self.forceSRVRefresh = forceSRVRefresh
        self.sortUsers = sortUsers
    }
}

//            let res = await SwiftyPing.pingServer(serverUrl: serverURL)
//            print("got res: " + String(res.duration))

//let servers = ["buzz.manacube.com",
//               "play.MysticMC.co",
//               "buzz.netherite.gg",
//               "join.wildwoodsmp.com",
//               "buzz.bosscraft.net",
//               "buzz.pixelblockmc.com",
//               "Play.SiphonMC.net",
//               "mc.advancius.net",
//               "mc.thecavern.net",
//               "bedrock.pika.host",
//               "bedrock.jartex.fun",
//               "bedrock.akumamc.net",
//               "buzz.havoc.games",
//               "bedrock.opblocks.com",
//               "play.applemc.fun",
//               "buzz.cosmosmc.org",
//               "buzz.catcraft.net",
//               "play.blossomcraft.org",
//               "join.wildwoodsmp.com",
//               "buzz.netherite.gg",
//               "buzz.zedarmc.com",
//               "plateousmp.net",
//               "buzz.semisurvivalcraft.com",
//               "Play.MinePower.Org",
//               "play.vanillarealms.com",
//            ]

let servers = [
    "tomershemesh.me"
]

let servers2 = [
    "mslc.mc-complex.com",
    "mcslp.pika.host",
    "msl.pixelmonrealms.com",
    "mcslp.jartex.fun",
    "play.penguin.gg",
    "akumamc.net",
    "play.neocubest.com",
    "lobby.havoc.games",
    "fun.opblocks.com",
    "play.anubismc.com",
    "play.smashmc.co",
    "msl.applemc.fun",
    "mcsl.astrocraft.org",
    "msl.ultimis.net",
    "mcsl.oneblockmc.com",
    "play.extremecraft.net",
    "mc.gamster.org",
    "play.pokesaga.org",
    "mc.lotc.co",
    "plateousmp.net",
    "fun.oplegends.com",
    "mcsl.zedarmc.com",
    "play.vulengate.com",
    "Play.PokeFind.co",
    "play.underblock.gg",
    "skyblock.net",
    "play.fishonmc.net",
    "sl.minecadia.com",
    "join.mccentral.org",
    "fly.join-mineland.online",
    "Herobrine.org",
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
    //    for serverURL in servers {
    //    let statusCheckerTask = Task {
    //        let server = SavedMinecraftServer(id: UUID(), serverType: .Java, name: "", serverUrl: serverURL, serverPort: 25565)
    //            let status = await ServerStatusChecker.checkServer(server: server)
    //            print("👉: " + serverURL + "   -   " + status.version + "  -   " + status.status.rawValue)
    //        }
    //    }
}
