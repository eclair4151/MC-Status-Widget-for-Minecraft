//
//  ProgressView.swift
//  MinecraftServerStatusHSWidgetExtension
//
//  Created by Tomer on 2/7/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import SwiftUI

struct ProgressView: View {
    var progress: CGFloat
    var bgColor = Color.black.opacity(0.2)
    var filledColor = Color.blue

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
