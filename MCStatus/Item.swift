//
//  Item.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 6/27/23.
//

import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
