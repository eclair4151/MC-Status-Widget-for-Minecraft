//
//  ImageHelper.swift
//  MCStatusDataLayer
//
//  Created by Tomer Shemesh on 10/10/24.
//

import Foundation
import UIKit

class ImageHelper {
    static func convertFavIconString(favIcon: String?) -> UIImage? {
        if let favIconString = favIcon, favIconString != "" {
            let favIconParts = favIconString.split(separator: ",")
            guard favIconParts.count == 2 else {
                return nil
            }
            if let decodedData = Data(base64Encoded: String(favIconParts[1]), options: .ignoreUnknownCharacters) {
                return UIImage(data: decodedData)
            }
        }
        return nil
    }
}




