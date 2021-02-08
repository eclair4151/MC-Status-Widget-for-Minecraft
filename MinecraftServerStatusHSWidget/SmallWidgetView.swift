//
//  SmallWidgetView.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer on 2/7/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI
import Intents
import WidgetKit

struct SmallWidgetView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color("WidgetBackground")
            VStack {
                HStack {
                    Image(uiImage: entry.viewModel.icon).resizable()                .scaledToFit().frame(width: 32.0, height: 32.0)
                    Image(systemName: entry.viewModel.statusIcon).font(.system(size: 32)).foregroundColor(Color(entry.viewModel.statusColor))
                    Text(entry.viewModel.lastUpdated).bold()
                }.frame(height:32).padding(.top,25).padding(.bottom,6)
                Text(entry.viewModel.serverName).fontWeight(.bold).frame(height:32).padding(.leading, 6).padding(.trailing, 6)
                Spacer()
                HStack {
                    Text(entry.viewModel.progressString)
                    ProgressView(progress: CGFloat(entry.viewModel.progressValue)).frame(height:10)
                }.padding(EdgeInsets(top: 0, leading: 8, bottom: 40, trailing: 8)).frame(height:32)
               
            }
        }
    }
}
