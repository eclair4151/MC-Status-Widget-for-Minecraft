//
//  ServerRowView 2.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 9/27/24.
//


//
//  ServerRowView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 9/25/24.
//

import SwiftUI
import MCStatusDataLayer

struct ServerRowView2: View {
    
    var body: some View {
        
        
        HStack {

            Image(uiImage: UIImage())
                .resizable()
                .frame(width: 50.0, height: 50.0)
                .background(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.2))
                .aspectRatio(contentMode: .fit)
                .padding([.trailing], 5)
            
            VStack(spacing: 5) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Server Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Online - 20/40")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                    }
                    Spacer()
                    ProgressView().padding([.trailing], 5)
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

#Preview {
    ServerRowView2()
//    let vm = ServerStatusViewModel(modelContext: , server: <#T##SavedMinecraftServer#>)
}
