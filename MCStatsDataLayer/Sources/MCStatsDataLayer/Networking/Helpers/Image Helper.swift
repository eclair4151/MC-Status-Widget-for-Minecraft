import SwiftUI

public class ImageHelper {
    public static func favIconString(_ favIcon: String?) -> UniversalImage? {
        guard let favIcon, !favIcon.isEmpty else {
            return nil
        }
        
        let favIconParts = favIcon.split(separator: ",")
        
        guard
            favIconParts.count == 2,
            let decodedData = Data(base64Encoded: String(favIconParts[1]), options: .ignoreUnknownCharacters)
        else {
            return nil
        }
        
        return UniversalImage(data: decodedData)
    }
}
