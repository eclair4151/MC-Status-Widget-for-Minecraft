//
//  JavaServerStatusParser.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 7/30/23.
//

import Foundation

class JavaServerStatusParser: ServerStatusParserProtocol {
    static func parseServerResponse(stringInput: String) -> ServerStatus {
        
        
        
        
        return ServerStatus()
    }
}


//    // move this logic out
//    // § is a section-sign which is used for formatting legacy style MOTD
//    // https://minecraft.fandom.com/wiki/Formatting_codes
//    // newer systems use the JSON based system
//    // https://minecraft.fandom.com/wiki/Raw_JSON_text_format
//    public func setDescriptionString(description: String?) {
//        guard description != nil else {
//            self.description = ""
//            return
//        }
//
//        var strDesc = description!
//        strDesc = strDesc.replacingOccurrences(of: "\n", with: " ")
//        strDesc = strDesc.replacingOccurrences(of: "§.", with: "", options: .regularExpression)
//
//        self.description = strDesc.trimmingCharacters(in: .whitespacesAndNewlines) + "    "
//    }

// other parsing code thats irrelevant
//            let objDesc = try? container.decode(Description.self, forKey: .description)
//            if let des = objDesc {
//                if (!(des.text?.isEmpty ?? true)) {
//                    strDesc = des.text
//                } else if let extras = des.extra, extras.count > 0 {
//                    strDesc = extras.reduce("", { previousString, nextExtra in
//                        return previousString + (nextExtra.text ?? "")
//                    })
//                }
//            }
