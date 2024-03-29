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


struct CircularAccessoryWidgetView2 : View {
    var entry: LockscreenProvider.Entry

    var body: some View {
#if !targetEnvironment(macCatalyst)
        if #available(iOSApplicationExtension 16.0, *) {
        
           
            Gauge (value: entry.viewModel.progressValue) {
                
                if let statusIcon = entry.viewModel.statusIcon {
                    Image(systemName: statusIcon)
                        .font(.system(size: 24))
                        .foregroundColor(
                            Color.unknownColor
                        )
                        .background(Color.white.mask(Circle()).padding(4)
                        )
                     
                } else if(entry.viewModel.isDefaultView) {
                    Text("Edit Widget").padding(2) .multilineTextAlignment(.center)
                } else {
                    
                    Image(uiImage: entry.viewModel.icon).resizable()
                        .scaledToFit().frame(width: 25.0, height: 25.0).padding(0).offset(x: 0,y: -1)
                }
            }
            .gaugeStyle(.accessoryCircularCapacity)
        } else {
            Text("Not implemented")
        }
    #endif
    }
}


#if !targetEnvironment(macCatalyst)
@available(iOSApplicationExtension 16.0, *)
struct MinecraftServerStatusLSWidget_CircularPreview2: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusLSWidgetEntryView(entry: ServerStatusLSSnapshotEntry(date: Date(), configuration: ServerSelectNoThemeIntent(), viewModel: WidgetEntryViewModel()), widgetType: .OnlyImage)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
#endif
