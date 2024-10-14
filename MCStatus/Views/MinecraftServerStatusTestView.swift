//
//  MinecraftServerStatusView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 9/30/24.
//

import SwiftUI
import MCStatusDataLayer

struct MinecraftServerStatusTestView: View {
    // Sample data for the server status
    var serverName: String = "Zero's Server"
    var serverType: String = "Java"
    var serverVersion: String = "Paper 1.21"
    var serverAddress: String = "myserver.com:25565"
    var srvRecordValue: String = "srv: otherserver.com:25565"

    var pingValue: String = "100ms"
    var isOnline: Bool = true
    var currentPlayers: Int = 12
    var maxPlayers: Int = 20
    var onlinePlayers: [Player] = [Player(name: "Player1", uuid: "c5ef3347-4593-4f39-8bb1-2eaa40dd986e")]

    var body: some View {
        GeometryReader { proxy in
                // List of online players
            LazyVStack {
                    Section(header: Spacer(minLength: 0)) {
                        
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 0) {
                            
                            Image("DefaultIcon")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(15)
                                .background(Color.serverIconBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 15))                              .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(hex: "6e6e6e"), lineWidth: 2))
                                .frame(width: 120)
                                .padding([.trailing], 16)
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 5, y: 5) // Drop shadow
     
                            
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(serverName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(serverAddress)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryTextColor)
                                    .lineLimit(1)
                                Text(srvRecordValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryTextColor)
                                    .lineLimit(1)
                                // Status pill
                                
                                HStack {
                                    Text(isOnline ? "Online" : "Offline")
                                    .frame(minWidth: 45)
                                        .padding([.trailing, .leading], 14)
                                        .padding([.bottom, .top], 7)
//                                        .background(Color.statusBackgroundGreen)
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                        .font(.subheadline)
                                    
                                    HStack {
                                        Image(systemName: "wifi")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 15, height: 15)
                                        Text("100ms")
                                            
                                            .font(.subheadline)
                                        
                                        
                                    }.padding([.trailing, .leading], 14)
                                        .padding([.bottom, .top], 7)
                                        .background(isOnline ? Color.green : Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                }.padding(.top, 10)

                                    
                             
                            }
                            
                        }
                        HStack(alignment: .center) {
                            Text(serverType)
                                .font(.subheadline)
                                .padding([.trailing, .leading], 6)
                                .padding([.bottom, .top], 3)
                                .background(Color.standoutPillGrey)
                                .cornerRadius(6)
                                .foregroundColor(.tertiaryTextColor)
                                .bold()
                            Text(serverVersion)
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundColor(.secondaryTextColor)
                        }
                        
                        
                        
                        Text("This is a MOTD from a server!\nNew stuff coming soon!")
                                    .font(.custom("Avenir", size: 20)) // Use a Minecraft-like font
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Make the Text view full width
                                    .foregroundColor(.white) // Set text color to white for contrast
                                    .background(Color.MOTDBackground) // Darker background
                                    .cornerRadius(15) // Rounded corners
                                    .padding([.top,.bottom],10) // Additional padding around the view
                                    .shadow(color: Color.black.opacity(0.5), radius: 5) // Optional shadow for depth

                        
                        Text("Players: \(currentPlayers)/\(maxPlayers)")
                            .font(.headline)
                            .padding([.top, .bottom], 4)
                        // Full-width progress bar
                        CustomProgressView(progress: CGFloat(0.3))
                            .frame(height:8)
                        
    
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.appBackgroundColor)
                    
                    Section {
                        ForEach(onlinePlayers) { player in
                            HStack(spacing: 0) {
                                AsyncImage(url: URL(string: "")){ image in
                                           image
                                               .resizable()
                                               .scaledToFill()
                                       } placeholder: {
                                           // 2
                                           ProgressView()
                                               .opacity(0.3)
                                               .padding()
                                               .frame(width: 40, height: 40)
                                               .background(Color.gray.opacity(0.1))
                                       }
                                       .cornerRadius(3)
                                       .frame(width: 40, height: 40)
                                       .padding([.trailing], 16)
                                   Text(player.name)
           
                           }.listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                        }
                    } footer: {
                        Text("*Player list limited to 12 users by server").frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                }.listStyle(.insetGrouped).listSectionSpacing(10).environment(\.defaultMinListHeaderHeight, 0)

        }.background(Color.appBackgroundColor)
    }
}


#Preview {
    MinecraftServerStatusTestView()
}
