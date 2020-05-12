//
//  ServerStatusViewModel.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 6/1/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftyJSON

//server model that is mapped to a row of the table.
public class ServerStatusViewModel {
    init() {
        self.loading = true
        self.serverData = JSON.null
    }
    
    var loading: Bool
    var serverData: JSON
    var serverStatus: ServerStatus? = nil

}
