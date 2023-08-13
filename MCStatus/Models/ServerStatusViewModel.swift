//
//  ServerStatusViewModel.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/9/23.
//
import Foundation

enum LoadingStatus {
    case Loading, Finished
}

@Observable
class ServerStatusViewModel: Identifiable {
    let server: SavedMinecraftServer
    var status: ServerStatus?
    var loadingStatus = LoadingStatus.Loading
    
    init(server: SavedMinecraftServer, status: ServerStatus? = nil) {
        self.server = server
        self.status = status
    }
    
    func reloadData() {
        Task {
            loadingStatus = .Loading
            let statusResult = await ServerStatusChecker.checkServer(server: server)
            self.status = statusResult
//            StatusCheckerCache.addStatusToCache(server: server, status: statusResult)
            loadingStatus = .Finished
        }
    }
}
