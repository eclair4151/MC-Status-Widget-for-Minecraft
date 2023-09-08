//
//  ServerStatusViewModel.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/9/23.
//
import Foundation

public enum LoadingStatus: String {
    case Loading, Finished
}

@Observable
public class ServerStatusViewModel: Identifiable {
    public let server: SavedMinecraftServer
    public var status: ServerStatus?
    public var loadingStatus = LoadingStatus.Loading
    
    public init(server: SavedMinecraftServer, status: ServerStatus? = nil) {
        self.server = server
        self.status = status
    }
    
    public func reloadData() {
        Task {
            loadingStatus = .Loading
            // DONT DO THIS, LET USER PASS IN FUNCTION WHICH WILL RELOAD DATA TO ALLOW REUSE IN WATCH
            let statusResult = await ServerStatusChecker.checkServer(server: server)
            self.status = statusResult
            loadingStatus = .Finished
        }
    }
}
