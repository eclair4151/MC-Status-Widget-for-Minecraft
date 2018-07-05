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
        self.error = false
        self.loading = true
        self.serverData = JSON.null
    }
    
    var loading: Bool
    var error: Bool
    var serverData: JSON

}
