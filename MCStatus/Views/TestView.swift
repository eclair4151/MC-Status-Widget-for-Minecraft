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

struct TestView: View {
    
    var body: some View {
        
        
            
            VStack() {
                Text("Serever name")
                    .font(.title)
                    .fontWeight(.bold)
                
//                        Text(serverType)
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
                
                // Status pill
                Text(true ? "Online" : "Offline")
                    .padding(8)
                    .background(true ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }


    }
}

#Preview {
    TestView()
//    let vm = ServerStatusViewModel(modelContext: , server: <#T##SavedMinecraftServer#>)
}
