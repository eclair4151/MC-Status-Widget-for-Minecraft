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
                    Text(status.getWatchDisplayText())
                        .font(.footnote)
                        .foregroundStyle((status.status == .Offline) ? .red : .primary)
                    
                } else {
                    HStack {
                        Text(viewModel.server.name).bold()
                            .minimumScaleFactor(0.65)
                            .lineLimit(1)
                        ProgressView().frame(width: 30, height: 30)
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
