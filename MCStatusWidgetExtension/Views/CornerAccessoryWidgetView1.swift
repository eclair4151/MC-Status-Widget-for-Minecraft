//
//  CircularAccessoryWidgetView1.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/11/24.
//


//
//  CircularAccessoryWidgetView.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer Shemesh on 10/4/22.
//  Copyright © 2022 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI
import Intents
import WidgetKit


struct CornerAccessoryWidgetView1 : View {
    var entry: LockscreenProvider.Entry

    private var iconSize: CGFloat {
        return 27
    }
    
   
    var body: some View {
#if !targetEnvironment(macCatalyst)
        ZStack {
            if let statusIcon = entry.viewModel.statusIcon {
                Image(systemName: statusIcon)
                    .font(.system(size: iconSize))
                    .widgetAccentable()

            } else if(entry.viewModel.viewType == .Unconfigured) {
                Text("...")
            } else {
                if #available(iOSApplicationExtension 18.0, watchOS 11.0, *) {
                    Image(uiImage: entry.viewModel.icon)
                        .resizable()
                        .widgetAccentedRenderingMode(WidgetAccentedRenderingMode.accentedDesaturated)
                        .scaledToFit().frame(width: iconSize, height: iconSize).padding(0)
                        .widgetAccentable()
                    
                } else {
                    Image(uiImage: entry.viewModel.icon)
                        .resizable()
                        .scaledToFit().frame(width: iconSize, height: iconSize).padding(0)
                        .widgetAccentable()
                    
                }
            }
            Button(intent: RefreshWidgetIntent()) {
                Color.clear
            }
            .buttonStyle(PlainButtonStyle())
        }.padding(0).widgetLabel {
            Gauge(value: entry.viewModel.progressValue) {
                 Text("")
              } currentValueLabel: {
                 Text("")
              } minimumValueLabel: {
                  Text(String(entry.viewModel.playersOnline)) // Watch out for clipping)
              } maximumValueLabel: {
                  Text(String(entry.viewModel.playersMax)) // Watch out for clipping
              }
              .tint(Color(hex: "#194485"))
            .gaugeStyle(.accessoryLinearCapacity)
        }
        
        

    #endif
    }
}


