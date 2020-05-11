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


public func getServerStatus(address: String, port: Int) {
    
    let client = TCPClient(address: address, port: Int32(port))
    switch client.connect(timeout: 10) {
      case .success:
        // Connection successful 🎉
        print("woo")
      case .failure(let error):
        // 💩
        print("boo")
    }
    
  //  let res = client.connect(timeout: 5)
    print("test")

}
