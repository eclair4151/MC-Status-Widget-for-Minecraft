//
//  UserDefaultHelper 2.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/13/24.
//


//
//  UserDefaultHelper.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 8/6/23.
//

import Foundation
import MCStatusDataLayer

class ConfigHelper {
    
    static func getServerCheckerConfig() -> ServerCheckerConfig {
        return ServerCheckerConfig(sortUsers: UserDefaultHelper.sortUsersByName())
    }
    
}



