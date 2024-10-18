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
        MinecraftServerStatusLSWidget1()
        MinecraftServerStatusLSWidget2()
    }
}
