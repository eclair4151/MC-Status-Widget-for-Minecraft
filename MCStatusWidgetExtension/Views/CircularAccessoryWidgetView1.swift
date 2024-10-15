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


struct CircularAccessoryWidgetView1 : View {
    var entry: LockscreenProvider.Entry

    private var iconSize: CGFloat {
        #if os(watchOS)
        return 15
        #else
        return 18
        #endif
    }
    
    private var iconTopPadding: CGFloat {
        #if os(watchOS)
        return 4
        #else
        return 0
        #endif
    }
    var body: some View {
        
#if !targetEnvironment(macCatalyst)
        Gauge (value: entry.viewModel.progressValue) {
            VStack(spacing: 1) {
                ZStack {
                    HStack(spacing: 4) { // Adjust spacing as needed
                        if let statusIcon = entry.viewModel.statusIcon {
                            Image(systemName: statusIcon)
                                .font(.system(size: iconSize))
                                .foregroundColor(
                                    Color.unknownColor
                                )
                                .background(Color.white.mask(Circle()).padding(2)
                                ).widgetAccentable()
                             
                        } else if(entry.viewModel.viewType == .Unconfigured) {
                            Text("Edit Widget").padding(2) .multilineTextAlignment(.center)
                        } else {
                            if #available(iOSApplicationExtension 18.0, watchOS 11.0, *) {
                                Image(uiImage: entry.viewModel.icon)
                                    .resizable()
                                    .widgetAccentedRenderingMode(WidgetAccentedRenderingMode.accentedDesaturated)
                                    .scaledToFit().frame(width: iconSize, height: iconSize).padding(0)
                                    .padding(.top, iconTopPadding)
                                    .widgetAccentable()
                                    
                            } else {
                                Image(uiImage: entry.viewModel.icon)
                                    .resizable()
                                    .scaledToFit().frame(width: iconSize, height: iconSize).padding(0)
                                    .padding(.top, iconTopPadding)
                                    .widgetAccentable()
                                    
                            }
                            
                        }
                    }
                    Button(intent: RefreshWidgetIntent()) {
                        Color.clear
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text(entry.viewModel.progressString).padding(.bottom, 4).padding(.horizontal,2).minimumScaleFactor(0.01).fontWeight(.semibold)
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)

    #endif
    }
}


#if !targetEnvironment(macCatalyst)
struct MinecraftServerStatusHSWidget_CircularPreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusLSWidgetEntryView(entry: ServerStatusLSSnapshotEntry(date: Date(), configuration: ServerSelectNoThemeWidgetIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
#endif
