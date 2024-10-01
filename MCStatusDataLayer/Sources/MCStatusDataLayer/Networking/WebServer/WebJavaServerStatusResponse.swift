//
//  WebServerStatusResponse.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 8/6/23.
//

import Foundation


class WebJavaServerStatusResponse: Decodable {
    let online: Bool
    let version: WebJavaResponseVersion?
    let players: WebJavaResponsePlayers?
    let motd: WebJavaResponseMOTD?
    let icon: String?
}

class WebJavaResponseVersion: Decodable {
    let name_clean: String
}


class WebJavaResponsePlayers: Decodable {
    let online: Int
    let max: Int
    let list:[WebJavaResponsePlayer]
}


class WebJavaResponsePlayer: Decodable {
    let name_clean: String
    let uuid: String
}

class WebJavaResponseMOTD: Decodable {
    let raw: String
}
