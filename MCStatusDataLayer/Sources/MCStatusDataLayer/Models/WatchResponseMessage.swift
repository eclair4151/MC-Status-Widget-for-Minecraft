//
//  WatchResponseMessage.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 8/21/23.
//

import Foundation
public class WatchResponseMessage: Codable {
    public var id: UUID
    public var status: ServerStatus
    
    public init(id: UUID, status: ServerStatus) {
        self.id = id
        self.status = status
    }
}
