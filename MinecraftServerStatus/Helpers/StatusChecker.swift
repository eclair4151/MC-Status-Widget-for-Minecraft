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
    let address: String
    let port: Int
    var attemptLegacy = true
    
    init(addressAndPort: String) {
        let addressPieces = addressAndPort.splitPort()
        self.address = addressPieces.address
        self.port = addressPieces.port ?? 25565
    }
    

    private func getStatusBg(listener: @escaping (ServerStatus) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard self.isConnectedToInternet() else {
                  listener(ServerStatus(status: .Unknown))
                  return
            }
            
           // self.getAddressIp(address: self.address)

            //create tcp connection directly to minecraft server
            let client = TCPClient(address: self.address, port: Int32(self.port))
            switch client.connect(timeout: 3) {
                case .success:
                  // we connected, lets send the status request
                  let sendData = self.getStatusQueryData(address: self.address, port: self.port)
                  switch client.send(data: sendData) {
                    case .success:

                      guard let serverStatus = self.readAndParseStatusData(client: client) else {
                          listener(ServerStatus(status: .Unknown))
                          return
                      }

                      serverStatus.status = .Online
                      listener(serverStatus)

                      client.close()
                    case .failure(let error):
                        print(error)
                        listener(ServerStatus(status: .Offline))
                        client.close()
                  }


                case .failure(let error):
                    print(error)
                    //listener(ServerStatus(status: .Offline))
                    client.close()
                    if self.attemptLegacy {
                        self.getLegacyServer(server: "\(self.address)", listener: listener)
                    }
            }
        }
    }
    
    
    public func getStatus(listener: @escaping (ServerStatus) -> Void, attemptLegacy: Bool = true) {
        getStatusBg(listener: listener)
    }


    private func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    

    private func readAndParseStatusData(client: TCPClient) -> ServerStatus? {
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

        //drop the packet id (always 0)
        if data.count == 0 {
            return nil
        }
        
        data.removeFirst()

        //then read in the json length which we dont care about since we are reading the rest of the response anyway
        _ = readVariableSizedInt(bytes: &data)

        //make sure the rest is a valid string
        guard let response = String(bytes: data, encoding: .utf8) else {
            return nil
        }
        
        //idk wtf these things are
        let jsonData = response.replacingOccurrences(of: "§.", with: "", options: .regularExpression).data(using: .utf8)!

        //attempt to parse it into our json
        return try? JSONDecoder().decode(ServerStatus.self, from: jsonData)
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
    private func getStatusQueryData(address: String, port: Int) -> [Byte] {
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

        //now prepend the second message which is a hardcoded 0 to ask for the status. since it is tcp we can write both requests in the same call
        data.append(0x01) //length of following status packet (always 1)
        data.append(0x00) //status packet (always 0)

        return data
    }


    // Why do people like to make things difficult
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


    
    private func getLegacyServer(server:String, listener: @escaping (ServerStatus) -> Void) {
        AF.request("https:/api.mcsrvstat.us/2/" + server).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                if json["online"].boolValue {
                    let status = ServerStatus(status: .Online)
                    
                    //description
                    let description = Description()
                    description.text = json["motd"]["clean"].array?.reduce("", { prev, next in
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

