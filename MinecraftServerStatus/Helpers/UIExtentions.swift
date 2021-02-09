//
//  UIExtentions.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 6/1/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

/**
 * Method to allow getting a color from a hex string
 * https://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values
 */
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension String {
    func splitPort() -> (address: String, port: Int?) {
        let parts = components(separatedBy: ":")
        let address = parts[0]
        var port: Int? = nil
        if parts.count > 1 {
            port = Int(parts[1])
        }
        return (address, port)
    }
}
/**
 * Method to underline a textfield
 */
extension UITextField {
    func underline()
    {
        let border = CALayer()
        let width = CGFloat(2.0)
        
        border.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}



extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition { transform(self) }
        else { self }
    }
}


extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
