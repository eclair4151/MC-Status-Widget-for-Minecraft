//
//  BedrockServerStatusChecker.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 8/2/23.
//

import Foundation
import Network

class BedrockServerStatusChecker: ServerStatusCheckerProtocol {
    let serverAddress: String
    let port: Int
    
    required init(serverAddress: String, port: Int) {
        self.serverAddress = serverAddress
        self.port = port
    }
    
    func checkServer() async throws -> String {
        // create UDP connection directly to minecraft server
        let commandClient = UDPClient(address: self.serverAddress, port: Int32(self.port)) { responseType, udpClient, data in
            udpClient?.connection.cancel()

            guard responseType == .SUCCESS, let responseData = data else {
                // throw error
                return
            }
            
            // read data.
            // 1 byte packet id, 8 byte timestamp, 8 byte server id, 16 byte magic data
            // then  2 bytes for the length of the following server data message
            // 1 + 8 + 8 + 16 + 2 = 35
            // everything after byte 35 is the string response
         
            //confirm we recived the correct packet id and all the expected data
            guard responseData[0] == 0x1c else {
                // throw error
                return
            }

            // this is an assumption that the response fits in 65kb since we are assuming the message length value fits in 2 bytes.
            // this will fail if it response is larger. Never seen anything even 10% that size so will deal with that issue later if it comes up.
            let serverDataBytes = responseData.dropFirst(35)

            guard let serverDataString = String(bytes: serverDataBytes, encoding: .utf8) else {
                // throw error
                return
            }
            
            // return result string
            
        }
        commandClient?.send(self.getBedrockStatusQueryData())
        
        
        return ""
    }
    
    func getParser() -> ServerStatusParserProtocol.Type {
        return BedrockServerStatusParser.self
    }
    
    
    
    /** Minecraft protocol can be found here: https://wiki.vg/Raknet_Protocol#Unconnected_Ping
     * sends a request directly to the minecraft server for a ping request.
     1. Client sends:
       1a. \x01 , unsigned 64bit long timestamp, 16 bytes of magic data predefined by the API
     2. Server responds with:
       2a.  packet id (0x1c), timestamp (uint64), serverid (uint64), 16 bytes of the same magic data, the following string length (uint16), and then the string of length defined in the previous uint16
       2b. the string of bytes representing the server like the following
       
       Edition (MCPE or MCEE for Education Edition);MOTD line 1;Protocol Version;Version Name;Player Count;Max Player Count;Server Unique ID;MOTD line 2;Game mode;Game mode (numeric);Port (IPv4);Port (IPv6);
       
       EX: MCPE;HL NEW MAPS;554;1.19.30;274;284;-6441182470932281358;WaterdogPE Proxy;Survival;1;19
     */
    private func getBedrockStatusQueryData() -> Data {
        var data: [UInt8] = []
        
        let magicData: [UInt8] = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, 0x00, 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe,
                         0xfd, 0xfd, 0xfd, 0xfd, 0x12, 0x34, 0x56, 0x78]
        data.append(0x01) //packet id (always 1)
        data.append(contentsOf: magicData)

        return Data(bytes: data, count: data.count)
    }
}
