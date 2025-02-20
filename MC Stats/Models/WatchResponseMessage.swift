//
//  WatchResponseMessage.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 8/21/23.
//

import Foundation
class WatchResponseMessage: Codable {
    var id: UUID
    var status: ServerStatus
    
    init(id: UUID, status: ServerStatus) {
        self.id = id
        self.status = status
    }
}
