//
//  WatchRequestMessage.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/21/23.
//

import Foundation

class WatchRequestMessage: Codable {
    var servers: [SavedMinecraftServer] = []
}
