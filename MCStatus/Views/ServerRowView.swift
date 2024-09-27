//
//  ServerRowView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 9/25/24.
//

import SwiftUI
import MCStatusDataLayer

struct ServerRowView: View {
    var viewModel: ServerStatusViewModel
    
    var body: some View {
        
        
        HStack {

            Image(uiImage: viewModel.serverIcon)
                .resizable()
                .frame(width: 50.0, height: 50.0)
                .background(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.2))
                .aspectRatio(contentMode: .fit)
                .padding([.trailing], 5)
            
            VStack(spacing: 5) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.server.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        if let status = viewModel.status {
                            Text(status.getDisplayText())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text(viewModel.loadingStatus.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                        }
                        
                    }
                    Spacer()
                    if viewModel.loadingStatus == .Loading {
                        ProgressView().padding([.trailing], 5)
                    }
                }
                CustomProgressView(progress: CGFloat(0.5))
                                        .frame(height:8)
            }

        }
//                .background(Color(.systemBackground))
//                .cornerRadius(8)
//                .shadow(radius: 2)
    }
}

//#Preview {
////    ServerRowView(title: "test", subtitle: "subtitle")
////    let vm = ServerStatusViewModel(modelContext: , server: <#T##SavedMinecraftServer#>)
//}
