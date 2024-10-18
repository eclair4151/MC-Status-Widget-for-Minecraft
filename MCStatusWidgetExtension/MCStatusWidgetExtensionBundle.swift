//
//  MCStatusWidgetExtensionBundle.swift
//  MCStatusWidgetExtension
//
//  Created by Tomer Shemesh on 10/9/24.
//

import WidgetKit
import SwiftUI

@main
struct MCStatusWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        MinecraftServerStatusHSWidget()
        MinecraftServerStatusLSWidget1()
        MinecraftServerStatusLSWidget2()
    }
}
