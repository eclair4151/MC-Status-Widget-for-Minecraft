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


public func getServer(server:String, listener: @escaping (AFDataResponse<Any>) -> Void) {
    AF.request("https:/api.mcsrvstat.us/2/" + server).responseJSON(completionHandler: listener)
}

class StatusChecker {
    let address: String
    let port: Int
    
    init(addressAndPort: String) {
        let parts = addressAndPort.components(separatedBy: ":")
        self.address = parts[0]

        if parts.count > 1 {
            self.port = Int(parts[1]) ?? 25565
        } else {
            self.port = 25565
        }
    }
    

    
    
    public func getStatus(listener: @escaping (ServerStatus) -> Void) {
        
        guard isConnectedToInternet() else {
            listener(ServerStatus(status: .Unknown))
            return
        }
        
        //create tcp connection directly to minecraft server
        let client = TCPClient(address: address, port: Int32(port))
        switch client.connect(timeout: 5) {
          case .success:
            // we connected, lets send the status request
            let sendData = getStatusQueryData(address: address, port: port)
            switch client.send(data: sendData) {
              case .success:
                
                guard let serverStatus = readAndParseStatusData(client: client) else {
                    listener(ServerStatus(status: .Unknown))
                    return
                }
                
                serverStatus.status = .Online
                listener(serverStatus)


                client.close()

              case .failure(_):
                listener(ServerStatus(status: .Offline))
                client.close()
            }
            
            
          case .failure(_):
            listener(ServerStatus(status: .Offline))
            client.close()
        }
    }

    
    private func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }

    private func readAndParseStatusData(client: TCPClient) -> ServerStatus? {
        //read initial chunk of data
        var data: [Byte] = client.read(1024*10, timeout: 5) ?? []

        //start and see how long this message should be
        let expectedSize = readVariableSizedInt(bytes: &data)
        
        var maxRetry = 30
        //while we are still missing parts of the message we should keep reading
        while data.count < expectedSize {
            usleep(100000) //sleep for .1 seconds and keep reading
            data += client.read(1024*10, timeout: 5) ?? []
            maxRetry -= 1
            //timeout after 3 seconds of waiting
            if (maxRetry < 0) {
                return nil
            }
        }
        
        //drop the packet id (always 0)
        data.removeFirst()
        
        //then read in the json length which we dont care about since we are reading the reast of the response anyway
        _ = readVariableSizedInt(bytes: &data)
        
        //make sure the rest is a valid string
        guard let response = String(bytes: data, encoding: .utf8) else {
            return nil
        }
        
        //attempt to parse it into our json
        return try? JSONDecoder().decode(ServerStatus.self, from: response.data(using: .utf8)!)
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
            let byte = bytes.removeFirst()
            result |= (Int(byte) & 0b1111111) << shift
            shift += 7
            if (Int(byte) & 0b10000000) == 0 {
                return result
            }
        }

        return result
    }

}

