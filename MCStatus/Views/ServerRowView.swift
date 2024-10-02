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
    
    @State var isLoading = false
    var body: some View {
        
        
        HStack {

            Image(uiImage: viewModel.serverIcon)
                .resizable()
                .frame(width: 50.0, height: 50.0)
//                .background(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.05))
                .aspectRatio(contentMode: .fit)
                .padding([.trailing], 5)
            
            VStack(spacing: 5) {
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
                            
                        } else if isLoading{
                            Text(viewModel.loadingStatus.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                        }
                        
                    }
                    Spacer()
                    if isLoading {
                        ProgressView().padding([.trailing], 5)
                    }
                }
                    CustomProgressView(progress: CGFloat(viewModel.getPlayerCountPercentage()))
                        .frame(height:8)
                
                
                
                if UserDefaultHelper.showUsersOnHomesreen() {
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

        }.onChange(of: viewModel.loadingStatus, initial: true) { oldValue, newValue in
            // Update isLoading whenever loadingStatus changes
            isLoading = (newValue == .Loading)
        }
    }
    
}

//#Preview {
////    ServerRowView(title: "test", subtitle: "subtitle")
////    let vm = ServerStatusViewModel(modelContext: , server: <#T##SavedMinecraftServer#>)
//}
