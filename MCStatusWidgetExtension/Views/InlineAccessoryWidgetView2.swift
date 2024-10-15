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
            if entry.viewModel.viewType == .Unconfigured {
                Text("Edit Widget")
            } else {
                Text(entry.viewModel.progressString)
            }
          
            if let statusIcon = entry.viewModel.statusIcon {
                Image(systemName: statusIcon)
                    .font(.system(size: 18))
                    .foregroundColor(Color.unknownColor)
                    .widgetAccentable()
                    .background(Color.white.mask(Circle()).padding(2))
            } else if entry.viewModel.viewType != .Unconfigured {
                let imageNumber = min(100, max(0, Int((entry.viewModel.progressValue * 100).rounded(.towardZero))))
                let imageName = "ProgressBar\(imageNumber)"
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage:  uiImage).renderingMode(.template).padding()
                }
            }
        }
#endif
    }
}

