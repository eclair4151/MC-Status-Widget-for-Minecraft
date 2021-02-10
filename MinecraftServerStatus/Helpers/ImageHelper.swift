//
//  ImageHelper.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 1/25/21.
//  Copyright © 2021 ShemeshApps. All rights reserved.
//

import Foundation
import UIKit

class ImageHelper {
    static func convertFavIconString(favIcon: String?) -> UIImage? {
        if let favIconString = favIcon, favIconString != "" {
            let imageString = String(favIconString.split(separator: ",")[1])
            if let decodedData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
                return UIImage(data: decodedData)
            }
        }
        return nil
    }
    
}
