//
//  ServerStatusViewModel.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/9/23.
//
import Foundation
import UIKit
import SwiftUI
import SwiftData

public enum LoadingStatus: String {
    case Loading, Finished
}

@Observable
public class ServerStatusViewModel: Identifiable {
    public let server: SavedMinecraftServer
    public var status: ServerStatus?
    public var loadingStatus = LoadingStatus.Loading
    public var serverIcon = UIImage()
    private var modelContext: ModelContext
    
    public init(modelContext: ModelContext, server: SavedMinecraftServer, status: ServerStatus? = nil) {
        self.server = server
        self.status = status
        self.modelContext = modelContext
        loadIcon()
    }
    
    public func reloadData() {
        Task {
            loadingStatus = .Loading
            // DONT DO THIS, LET USER PASS IN FUNCTION WHICH WILL RELOAD DATA TO ALLOW REUSE IN WATCH
            let statusResult = await ServerStatusChecker.checkServer(server: server)
            self.status = statusResult
            if !statusResult.favIcon.isEmpty {
                server.serverIcon = statusResult.favIcon
                
                Task { @MainActor in
                    print("Going to insert updated model")
                    modelContext.insert(server)
                    print("inserted updated model")

                    do {
                        // Try to save
                        print("Going to save updated model")

                        try modelContext.save()
                    } catch {
                        // We couldn't save :(
                        print(error.localizedDescription)
                    }
                    print("saved updated model")
                }
                

            }
            loadIcon()
            loadingStatus = .Finished
        }
    }
    
    public func loadIcon() {
        var base64Icon = ""
        if let status, status.favIcon != "" {
            base64Icon = status.favIcon
        } else {
            base64Icon = server.serverIcon
        }
        
        guard !base64Icon.isEmpty else {
            return
        }
        
        let imageString = String(base64Icon.split(separator: ",")[1])
        if let decodedData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters),
           let decodedImage = UIImage(data: decodedData) {
                self.serverIcon =  decodedImage
            
        }
    }
}
