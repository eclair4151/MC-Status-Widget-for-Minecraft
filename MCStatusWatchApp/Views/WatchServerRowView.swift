//
//  ServerRowView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 9/25/24.
//

import SwiftUI
import MCStatusDataLayer
import Nuke
import NukeUI

struct WatchServerRowView: View {
    var viewModel: ServerStatusViewModel
    
    var body: some View {
        HStack() {
            Image(uiImage: viewModel.serverIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 40.0, height: 40.0)
                .cornerRadius(5)
                .background(Color.serverIconBackground)
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(hex: "6e6e6e"), lineWidth: 3))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .padding([.trailing], 5)
            
            VStack(alignment: .leading, spacing: 0) {
                if let status = viewModel.status {
                    Text(viewModel.server.name).bold()
                        .minimumScaleFactor(0.65)
                        .lineLimit(1)
                    HStack {
                        Text(status.getWatchDisplayText())
                            .font(.footnote)
                            .foregroundStyle((status.status == .Offline) ? .red : .primary)
                        if (viewModel.loadingStatus == .Loading) {
                            ProgressView().frame(width: 15, height: 15).scaleEffect(CGSize(width: 0.65, height: 0.65), anchor: .center)
                        } else if (viewModel.status?.source == .ThirdParty) {
                            Image(systemName: "globe")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10, height: 10)
                            
                        }
                    }
                    
                    
                    
                } else {
                    HStack {
                        Text(viewModel.server.name).bold()
                            .minimumScaleFactor(0.65)
                            .lineLimit(1)
                        ProgressView().frame(width: 20, height: 20).scaleEffect(CGSize(width: 0.8, height: 0.8), anchor: .center)
                    }
                }
                
                CustomProgressView(progress: viewModel.getPlayerCountPercentage())
                    .frame(height:6).padding(.vertical, 3)
            }
        }
    }
    
}

//#Preview {
////    ServerRowView(title: "test", subtitle: "subtitle")
////    let vm = ServerStatusViewModel(modelContext: , server: <#T##SavedMinecraftServer#>)
//}
