//
//  RectangularAccessoryWidgetView.swift
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


struct RectangularAccessoryWidgetView : View {
    var entry: LockscreenProvider.Entry

    var body: some View {
        
#if !targetEnvironment(macCatalyst)
        Gauge (value: entry.viewModel.progressValue) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    if let statusIcon = entry.viewModel.statusIcon {
                        Image(systemName: statusIcon)
                            .font(.system(size: 20))
                            .foregroundColor(
                                Color.unknownColor
                            )
                            .background(Color.white.mask(Circle()).padding(2)
                            )
                        
                    
                    } else {
                        Image(uiImage: entry.viewModel.icon).resizable()
                            .scaledToFit().frame(width: 18.0, height: 18.0).padding(0)
                    }
                    Text(entry.viewModel.serverName)
                    
                }
            
                Text(entry.viewModel.progressString)
            }
            
        }
        .gaugeStyle(.accessoryLinearCapacity)
         
#endif
    }
}


#if !targetEnvironment(macCatalyst)
struct MinecraftServerStatusHSWidget_RectanglePreview: PreviewProvider {
    static var previews: some View {
        MinecraftServerStatusLSWidgetEntryView(entry: ServerStatusLSSnapshotEntry(date: Date(), configuration: ServerSelectNoThemeWidgetIntent(), viewModel: WidgetEntryViewModel()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
#endif
