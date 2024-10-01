//
//  MinecraftServerStatusView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 9/30/24.
//

import SwiftUI
import MCStatusDataLayer

struct MinecraftServerStatusView: View {
    // Sample data for the server status
    var serverName: String = "Zero's Server"
    var serverType: String = "Java"
    var serverVersion: String = "Paper 1.21"
    var serverAddress: String = "myserver.com:25565"
    var srvRecordValue: String = "srv: otherserver.com:25565"

    var pingValue: String = "Ping: 100ms"
    var isOnline: Bool = true
    var currentPlayers: Int = 12
    var maxPlayers: Int = 20
    var onlinePlayers: [Player] = [Player(name: "Player1", id: "c5ef3347-4593-4f39-8bb1-2eaa40dd986e")]

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading) {
                    HStack(alignment: .top, spacing: 0) {
                        
                        Image("DefaultIcon")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 2))
                            .frame(width: proxy.size.width * 0.3)
                            .padding([.trailing], 16)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 5, y: 5) // Drop shadow
 
                        
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(serverName)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(serverAddress)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            Text(srvRecordValue)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            // Status pill
                                Text(isOnline ? "Online" : "Offline")
                                    .padding([.trailing, .leading], 18)
                                    .padding([.bottom, .top], 8)
                                    .background(isOnline ? Color.green : Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .padding(.top, 10)
                         
                        }
                        
                    }
                    HStack {
                        Text(serverType)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .bold()
                        Text("-")
                        Text(serverVersion)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Text(pingValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("This is a MOTD from a server!\nNew stuff coming soon!")
                                .font(.custom("Avenir", size: 20)) // Use a Minecraft-like font
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading) // Make the Text view full width
                                .foregroundColor(.white) // Set text color to white for contrast
                                .background(Color.black.opacity(0.75)) // Darker background
                                .cornerRadius(15) // Rounded corners
                                .padding([.top,.bottom],10) // Additional padding around the view
                                .shadow(color: Color.black.opacity(0.5), radius: 5) // Optional shadow for depth

                    
                    Text("Players: \(currentPlayers)/\(maxPlayers)")
                        .font(.headline)
                        .padding([.top, .bottom], 4)
                    // Full-width progress bar
                    CustomProgressView(progress: CGFloat(0.3))
                        .frame(height:8)
                    
                    
                }.padding([.leading], 20)
                    .padding([.top], 16)
                    .padding(.trailing, 20)
                
                
                // List of online players
                List {
                    ForEach(onlinePlayers) { player in
                        HStack(spacing: 0) {
                            AsyncImage(url: URL(string: "https://mc-heads.net/avatar/" + player.id)){ result in
                                       result.image?
                                           .resizable()
                                           .scaledToFill()
                                   }
                                   .cornerRadius(3)
                                   .background(.gray)
                                   .frame(width: 40, height: 40)
                                   .padding([.trailing], 16)
                               Text(player.name)
       
                       }.listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                    }
                }.listStyle(.insetGrouped).padding(.top, -10).zIndex(-1)
            }

        }.background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Server Status")
    }
}


#Preview {
    MinecraftServerStatusView()
}
