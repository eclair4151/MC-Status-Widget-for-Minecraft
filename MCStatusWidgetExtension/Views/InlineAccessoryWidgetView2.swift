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


struct InlineAccessoryWidgetView2 : View {
    var entry: LockscreenProvider.Entry

    var body: some View {
#if !targetEnvironment(macCatalyst)
        
        HStack(spacing: 3) {
            Button(intent: RefreshWidgetIntent()) {
                if entry.viewModel.viewType == .Unconfigured {
                    #if os(watchOS)
                    Text("...")
                    #else
                    Text("Edit Widget")
                    #endif
                } else {
                    Text(entry.viewModel.progressString)
                }
            }.buttonStyle(PlainButtonStyle())
            if let statusIcon = entry.viewModel.statusIcon {
                Image(systemName: statusIcon)
                    .font(.system(size: 18))
                    .widgetAccentable()
            } else if entry.viewModel.viewType != .Unconfigured {
                let imageNumber = 50// min(100, max(0, Int((entry.viewModel.progressValue * 100).rounded(.towardZero))))
                let imageName = "ProgressBar\(imageNumber)"
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage:  uiImage).padding().widgetAccentable()
                }
            }
        }
#endif
    }
}

