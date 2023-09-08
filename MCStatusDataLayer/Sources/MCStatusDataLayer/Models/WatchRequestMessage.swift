//
//  WatchRequestMessage.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/21/23.
//

import Foundation

public class WatchRequestMessage: Codable {
    public var servers: [SavedMinecraftServer] = []
    public init() {
        
    }
}
