//
//  RequestUtil.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 5/30/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSocket
import SwiftyJSON


class StatusChecker {
    
    
    var address: String
    var port: Int
    var serverType: Int
    
    
    init(addressAndPort: String, serverType: Int) {
        let addressPieces = addressAndPort.splitPort()
        self.address = addressPieces.address
        self.serverType = serverType

        if let serverPort = addressPieces.port {
            self.port = serverPort
        } else {
            if (self.serverType == ServerType.SERVER_TYPE_JAVA) {
                self.port = 25565
            } else {
                self.port = 19132
            }
        }
    }
    

  
    
    public func getStatus(listener: @escaping (ServerStatus) -> Void, attemptLegacy: Bool = true) {
        if (self.serverType == ServerType.SERVER_TYPE_JAVA) {
            getJavaStatusBg(listener: listener)
        } else {
            getBedrockStatusBg(listener: listener)
        }
    }


    private func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    

    
    
    
    
    
    private func getJavaStatusBg(listener: @escaping (ServerStatus) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard self.isConnectedToInternet() else {
                  listener(ServerStatus(status: .Unknown))
                  return
            }
            
            //create tcp connection directly to minecraft server
            let client = TCPClient(address: self.address, port: Int32(self.port))
            switch client.connect(timeout: 3) {
                case .success:
                  // we connected, lets send the status request
                  let sendData = self.getJavaStatusQueryData(address: self.address, port: self.port)
                  switch client.send(data: sendData) {
                    case .success:

                      guard let serverStatus = self.readAndParseJavaStatusData(client: client) else {
                            client.close()
                            // unable to parse response try third party backup
                            self.getLegacyJavaServer(server: "\(self.address)", listener: listener)
                            return
                      }

                      // we were able to connect and read to response. Server is online
                      serverStatus.status = .Online
                      listener(serverStatus)

                      client.close()
                    case .failure(let error):
                        print(error)
                        // unable to send data to server. try third party backup
                        self.getLegacyJavaServer(server: "\(self.address)", listener: listener)
                        client.close()
                  }


                case .failure(let error):
                    print(error)
                    client.close()
                
                    // unable to access server. try third party backup
                    self.getLegacyJavaServer(server: "\(self.address)", listener: listener)
                    
            }
        }
    }
    
    
    private func getBedrockStatusBg(listener: @escaping (ServerStatus) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard self.isConnectedToInternet() else {
                  listener(ServerStatus(status: .Unknown))
                  return
            }
            
            // create UDP connection directly to minecraft server
            let commandClient = UDPClient(address: self.address, port: Int32(self.port)) { responseType, udpClient, data in
                udpClient?.connection.cancel()

                guard responseType == .SUCCESS, let responseData = data else {

                    //Unable to connect. try third party backup
                    self.getLegacyBeckrockServer(listener: listener)
                    return
                }
                
                guard let serverStatus = self.parseBedrockStatusData(data: responseData) else {
                    //Unable to parse response data. Try third party backuop
                    self.getLegacyBeckrockServer(listener: listener)
                    return
                }
                
                //we were able to connect and parse the response. server is online
                serverStatus.status = .Online
                listener(serverStatus)
                
                
            }
            commandClient?.send(self.getBedrockStatusQueryData())
        }
    }
    
    
    
    
    
    
    
    
    
    /** Minecraft protocol can be found here: https://wiki.vg/Protocol#Clientbound
     * sends a request directly to the minecraft server for a ping request.
     1. Client sends:
       1a. \x00 (handshake packet containing the fields specified below)
       1b. \x00 (request)
     The handshake packet contains the following fields respectively:
         1. protocol version as a varint (\x00 suffices)
         2. remote address as a string
         3. remote port as an unsigned short
         4. state as a varint (should be 1 for status)
     2. Server responds with:
       2a. \x00 (JSON response)
     An example JSON string contains:
     {'players': {'max': 20, 'online': 0},
     'version': {'protocol': 404, 'name': '1.13.2'},
     'description': {'text': 'A Minecraft Server'}}
     */
    private func getJavaStatusQueryData(address: String, port: Int) -> [Byte] {
        var data: [Byte] = []
        let addressBytes:[Byte] = Array(address.utf8)

        data.append(0x00) //packet id (always 0)
        data.append(0x00) //protocol version (0-752, we can use 0 since this api was here since the start)

        // this is for the url of the length and string of the server
        let addressLengthByte = withUnsafeBytes(of: addressBytes.count) {
            $0[0]
        }
        data.append(addressLengthByte) //lenth of url we are about to send
        data += addressBytes //the address of the server


        // now for the server port. We gotta switch endians and make it a short (only 2 bytes)
        let portBytes = withUnsafeBytes(of: port) {
            [$0[1], $0[0]]
        }
        data += portBytes //the bytes for the server port

        data.append(0x01) //request type (status_handshake = 1)

        //calculate length of whole message (i have made a bad descision of locking the request size to 255 by only allowing a single byte of length,
        // but this is fine for now since i limit the url to 200 characters and the rest of the request is only like 10 bytes
        let handshakeLengthByte = withUnsafeBytes(of: data.count) {
            $0[0]
        }

        //insert the message length at the begining
        data.insert(handshakeLengthByte, at: 0)

        //now append the second message which is a hardcoded 0 to ask for the status. since it is tcp we can write both requests in the same call
        data.append(0x01) //length of following status packet (always 1)
        data.append(0x00) //status packet (always 0)

        return data
    }
    
    private func readAndParseJavaStatusData(client: TCPClient) -> ServerStatus? {
        //read initial chunk of data
        var data: [Byte] = client.read(1024*10, timeout: 3) ?? []

        //start and see how long this message should be
        let expectedSize = readVariableSizedInt(bytes: &data)

        var maxRetry = 30
        //while we are still missing parts of the message we should keep reading
        while data.count < expectedSize {
            usleep(100000) //sleep for .1 seconds and keep reading
            data += client.read(1024*10, timeout: 3) ?? []
            maxRetry -= 1
            //timeout after 3 seconds of waiting
            if (maxRetry < 0) {
                return nil
            }
        }

        //confirm we have data
        if data.count == 0 {
            return nil
        }
        
        //drop the packet id (always 0)
        data.removeFirst()

        //then read in the json length which we dont care about since we are reading the rest of the response anyway
        _ = readVariableSizedInt(bytes: &data)

        //make sure the rest is a valid string
        guard let response = String(bytes: data, encoding: .utf8) else {
            return nil
        }
        
        let jsonData = response.data(using: .utf8)!

        //attempt to parse it into a json using a custom parser defined in the object
        return try? JSONDecoder().decode(ServerStatus.self, from: jsonData)
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
        var data: [Byte] = []
        
        let magicData: [Byte] = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, 0x00, 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe,
                         0xfd, 0xfd, 0xfd, 0xfd, 0x12, 0x34, 0x56, 0x78]
        data.append(0x01) //packet id (always 1)
        data.append(contentsOf: magicData)

        return Data(bytes: data, count: data.count)
    }
    
    private func parseBedrockStatusData(data: Data) -> ServerStatus? {
        // read data.
        // 1 byte packet id, 8 byte timestamp, 8 byte server id, 16 byte magic data
        // then  2 bytes for the length of the following server data message
        // 1 + 8 + 8 + 16 + 2 = 35
        // everything after byte 35 is the string response
     
        //confirm we recived the correct packet id and all the expected data
        guard data[0] == 0x1c else {
            return nil
        }

        // this is a hack and assumes the response fits in 1 response, and no data will be sent after the server status string. Oh well.
        let serverDataBytes = data.dropFirst(35)

        guard let serverDataString = String(bytes: serverDataBytes, encoding: .utf8) else {
            return nil
        }

        let dataParts = serverDataString.split(separator: ";")

        guard dataParts.count > 7 else {
            return nil
        }

        //convert data
        let serverStatus = ServerStatus(status: .Online)
        serverStatus.setDescriptionString(description: dataParts[1] + "  |  " + dataParts[7])
        let players = Players()
        players.max = Int(dataParts[5]) ?? 0
        players.online = Int(dataParts[4]) ?? 0
        players.sample = []

        serverStatus.players = players

        let version = Version()
        version.name = String(dataParts[3])
        serverStatus.version = version
        return serverStatus
        
    }
    
    
    
    
    
    // https://en.wikipedia.org/wiki/Variable-length_quantity
    private func readVariableSizedInt(bytes: inout [Byte]) -> Int {
        var result = 0;
        var shift = 0;
        for _ in 0...bytes.count {
            if bytes.count == 0 {
                return 0
            }
            
            let byte = bytes.removeFirst()
            result |= (Int(byte) & 0b1111111) << shift
            shift += 7
            if (Int(byte) & 0b10000000) == 0 {
                return result
            }
        }

        return result
    }

    
    private func getLegacyBeckrockServer(listener: @escaping (ServerStatus) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://minecraftpinger.com/api/ping")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("no-cache", forHTTPHeaderField: "cache-control")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "accept-language")
        
        request.httpBody = Data(("\"" + self.address + ":" + String(self.port) + "\"").utf8)

        AF.request(request).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)

                if json["message"].exists() && json["message"].stringValue.lowercased().contains("offline") {
                    listener(ServerStatus(status: .Offline))
                    return
                }
                
                
                if !json["host"].exists() {
                    listener(ServerStatus(status: .Unknown))
                    return
                }
                
                
                let status = ServerStatus(status: .Online)
                    
                //description
                let description = json["motd"]["clean"].stringValue.replacingOccurrences(of: "\n", with: "  |  ")
                status.description = description

                //Players
                let players = Players()
                players.max = json["players"]["max"].int ?? 0
                players.online = json["players"]["online"].int ?? 0
                players.sample = []
                status.players = players

                //version
                let version = Version()
                version.name = json["version"]["name"].string ?? ""
                status.version = version

                //icon
                status.favicon = nil
                listener(status)

                

            case .failure(let error):
                if let _ = error.responseCode {
                    listener(ServerStatus(status: .Offline))
                } else {
                    listener(ServerStatus(status: .Unknown))
                }
            }
        }
    }
    
    
    private func getLegacyJavaServer(server:String, listener: @escaping (ServerStatus) -> Void) {
        AF.request("https:/api.mcsrvstat.us/2/" + server).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                if json["online"].boolValue {
                    let status = ServerStatus(status: .Online)
                    
                    //description
                    let description = json["motd"]["clean"].array?.reduce("", { prev, next in
                        return prev + " " + (next.string ?? "")
                    })
                    status.description = description
                    
                    //Players
                    let players = Players()
                    players.max = json["players"]["max"].int ?? 0
                    players.online = json["players"]["online"].int ?? 0
                    players.sample = json["players"]["list"].array?.compactMap { playerStr in
                        let sample = UserSample()
                        sample.name = playerStr.string ?? ""
                        return sample
                    }
                    status.players = players
                    
                    //version
                    let version = Version()
                    version.name = json["version"].string ?? ""
                    status.version = version
                    
                    //icon
                    status.favicon = json["icon"].string
                    listener(status)
                    
                } else {
                    listener(ServerStatus(status: .Offline))
                }
                
            case .failure(let error):
                print(error)
                listener(ServerStatus(status: .Unknown))
            }
        }
    }
}

