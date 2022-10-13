//
//  ContentView.swift
//  MC Status WatchApp Watch App
//
//  Created by Tomer Shemesh on 10/13/22.
//  Copyright © 2022 ShemeshApps. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var appData: String
    
    var body: some View {
        VStack {
            Image(systemName: "figure.dance")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(appData).multilineTextAlignment(.center).padding(10)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appData: "Minecraft Status Watch App")
    }
}
