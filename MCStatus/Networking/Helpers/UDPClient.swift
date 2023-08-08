//
//  UDPClient.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/8/22.
//  Copyright © 2022 ShemeshApps. All rights reserved.
//

import Foundation
import Network


enum UDPResponseType {
    case SUCCESS
    case ERROR
}


class UDPClient {
    
    var connection: NWConnection
    var address: NWEndpoint.Host
    var port: NWEndpoint.Port
    var listener: (_ responseType: UDPResponseType, _ client: UDPClient?, _ data: Data?) -> Void
    var didRecieveData = false
    
    var resultHandler = NWConnection.SendCompletion.contentProcessed { NWError in
        guard NWError == nil else {
            print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            return
        }
        
        print("data sent successfully")
    }

    init?(address newAddress: String, port newPort: Int32, listener: @escaping (_ responseType: UDPResponseType, _ client: UDPClient?, _ data: Data?) -> Void) {
        
        self.listener = listener
        
        guard
            let codedPort = NWEndpoint.Port(rawValue: NWEndpoint.Port.RawValue(newPort)) else {
                print("Failed to create connection address")
            self.listener(.ERROR, nil, nil)
            return nil
        }
        address = NWEndpoint.Host(newAddress)
        port = codedPort
        
        connection = NWConnection(host: address, port: port, using: .udp)
        connection.stateUpdateHandler = { newState in
            switch (newState) {
            case .ready:
                print("State: Ready")
                return
            case .setup:
                print("State: Setup")
            case .cancelled:
                print("State: Cancelled")
            case .preparing:
                print("State: Preparing")
            default:
                print("ERROR! State not defined!\n")
                self.listener(.ERROR, nil, nil)

            }
        }
        connection.start(queue: .global())
    }
    
    deinit {
        connection.cancel()
    }
    
    // SETUP WITH A 3 SECOND TIMEOUT
    func send(_ data: Data) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if (!self.didRecieveData) {
                self.listener(.ERROR, self, nil)
            }
        }
        print("Sending Data")
        self.connection.send(content: data, completion: self.resultHandler)


        self.connection.receiveMessage { data, context, isComplete, error in
            self.didRecieveData = true
            guard let data = data else {
                print("Error: Received nil Data")
                self.listener(.ERROR, self, nil)
                return
            }
            
            print("Received valid Data")

            self.listener(.SUCCESS,self,data)
        }
        
        
    }
}
