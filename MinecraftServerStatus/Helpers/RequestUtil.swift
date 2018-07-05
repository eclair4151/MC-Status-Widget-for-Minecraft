//
//  RequestUtil.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 5/30/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import Foundation
import Alamofire

public func getServer(server:String, listener: @escaping (DataResponse<Any>) -> Void) {
    Alamofire.request("https:/api.mcsrvstat.us/1/" + server).responseJSON(completionHandler: listener)
}
