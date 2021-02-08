//
//  MediumWidgetView.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer on 2/7/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI
import Intents
import WidgetKit

struct MediumWidgetView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color("WidgetBackground")
            VStack {
                HStack {
                   
                    Text("THIS IS A TEST").fontWeight(.bold).frame(height:32).padding(.leading, 6).padding(.trailing, 6)
                    Spacer()
                    HStack {
                        Text(entry.viewModel.progressString)
                        ProgressView(progress: CGFloat(entry.viewModel.progressValue)).frame(height:10)
                    }.padding(EdgeInsets(top: 0, leading: 8, bottom: 40, trailing: 8)).frame(height:32)
                   
                }
            }
        }
    }
}
