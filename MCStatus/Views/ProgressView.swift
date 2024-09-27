//
//  ProgressView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 9/27/24.
//


//
//  ProgressView.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer on 2/7/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI

struct CustomProgressView: View {
    var progress: CGFloat
    var bgColor = Color.gray
    var filledColor = Color.green

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(bgColor)
                    .frame(width: width,
                           height: height)
                    .cornerRadius(height / 2.0)

                Rectangle()
                    .foregroundColor(filledColor)
                    .frame(width: width * self.progress,
                           height: height)
                    .cornerRadius(height / 2.0)
            }
        }
    }
}
