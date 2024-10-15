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
                .scaledToFit()
                .frame(width: 65.0, height: 65.0)
                .cornerRadius(8)
                .background(Color.serverIconBackground)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "6e6e6e"), lineWidth: 3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding([.trailing], 5)
              
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.server.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        if let status = viewModel.status {
                            if (status.status == .Offline) {
                                Text(status.status.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .bold()
                            } else {
                                Text(status.getDisplayText())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                        } else if viewModel.loadingStatus == .Loading {
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
                    CustomProgressView(progress: CGFloat(viewModel.getPlayerCountPercentage()))
                        .frame(height:8)
                
                
                
                if UserDefaultHelper.shared.get(for: .showUsersOnHomesreen, defaultValue: true) {
                    let sampletext = viewModel.getUserSampleText()
                        Text(sampletext)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(0)
                            .frame(height:8)
                            .lineLimit(1)
                            .truncationMode(.tail)
                }
            }

        }
    }
    
}

//#Preview {
////    ServerRowView(title: "test", subtitle: "subtitle")
////    let vm = ServerStatusViewModel(modelContext: , server: <#T##SavedMinecraftServer#>)
//}
