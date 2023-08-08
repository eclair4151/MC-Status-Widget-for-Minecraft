//
//  JavaServerStatusParser.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 7/30/23.
//

import Foundation

class JavaServerStatusParser: ServerStatusParserProtocol {
    static func parseServerResponse(stringInput: String) throws -> ServerStatus {
        
        let jsonData = stringInput.data(using: .utf8)
        guard let jsonData = jsonData else {
            throw ServerStatusCheckerError.StatusUnparsable
        }

        //attempt to parse it into a json using a custom parser defined in the object
        let responseObject = try JSONDecoder().decode(JavaServerStatusResponse.self, from: jsonData)
        
        let formattedMOTDSections = if let desc = responseObject.description, let extras = desc.extra, !extras.isEmpty {
            parseJavaMOTD(input: desc)
        } else if let desc = responseObject.description, let motdText = desc.text {
            // had no extras, so its just a string. check if we have section signs. If we do send it though string parser. If not sent through json parser.
            if motdText.contains("§") {
                parseJavaMOTD(input: motdText)
            } else {
                parseJavaMOTD(input: desc)
            }
        } else {
            [FormattedMOTDSection]()
        }
        
        let status = ServerStatus()
        status.description = FormattedMOTD(messageSections: formattedMOTDSections)
        
        if let onlinePlayerCount = responseObject.players?.online {
            status.onlinePlayerCount = onlinePlayerCount
        }
        
        if let maxPlayerCount = responseObject.players?.max {
            status.maxPlayerCount = maxPlayerCount
        }
        
        if let version = responseObject.version?.name {
            status.version = version
        }
        
        if let favIcon = responseObject.favicon {
            status.favIcon = favIcon
        }
        
        status.playerSample = (responseObject.players?.sample ?? []).map { userSample in
            return Player(name: userSample.name)
        }
        status.status = .Online
        return status
    }
    
    
    
    
    
    
    
    // § is a section-sign which is used for formatting legacy style MOTD
    // https://minecraft.fandom.com/wiki/Formatting_codes
    //Idealy, i would have the same code for both java and bedrock MOTD parsing, but alas there are some subtle differences in the parsing code that make it just annoying enough to require breaking into 2 seperate functions (See other parser in BedrockServerStatusParser.
    static func parseJavaMOTD(input: String) -> [FormattedMOTDSection] {
        
        var motdSections:[FormattedMOTDSection] = []
        var currentSection = FormattedMOTDSection()
        var currentIndex = input.startIndex

        // walk through the MOTD string and look for section sign modifiers "§"
        while currentIndex < input.endIndex {
            if input[currentIndex] == "§" {
                // if we found the modifier, advance to the next char and see what it is
                currentIndex = input.index(after: currentIndex)
                let modifierKey = input[currentIndex]
                // apply formatter if it matches a known formatter value, then continue parsing string
                if let sectionFormatter = javaSectionSignFormatCodes[String(modifierKey)] {
                    // cap off current section, so next set can have new formatters.
                    // if the text is empty dont both adding it
                    if (!currentSection.text.isEmpty) {
                        motdSections.append(currentSection)
                    }
                    let newSection = FormattedMOTDSection()

                    if sectionFormatter != .Reset {
                        // if we are not resetting, copy the old formatters, and add the new one
                        newSection.color = currentSection.color
                        newSection.formatters = currentSection.formatters
                        newSection.formatters.insert(sectionFormatter)
                    }
                    currentSection = newSection
                } else if let colorFormatter = javaSectionSignColorFormats[String(modifierKey)] {
                    // if the text is empty dont bother adding it
                    if (!currentSection.text.isEmpty) {
                        motdSections.append(currentSection)
                    }
                    // in java edition only, when a new color is specified, all previous formatters are reset.
                    currentSection = FormattedMOTDSection()
                    currentSection.color = colorFormatter.rawValue
                }
            } else {
                currentSection.text.append(input[currentIndex])
            }
            
            // Manually increment the index
            currentIndex = input.index(after: currentIndex)
        }
        
        return motdSections
    }


    // newer systems use the JSON based system which is a recursive
    // https://minecraft.fandom.com/wiki/Raw_JSON_text_format
    static func parseJavaMOTD(input: JavaMOTDDescriptionSection, color: String = "", formatters: Set<MOTDFormatter> = []) -> [FormattedMOTDSection] {
        var response:[FormattedMOTDSection] = []
        
        var newFormatters = formatters
        
        if let bold = input.bold {
            if bold {
                newFormatters.insert(.Bold)
            } else {
                newFormatters.remove(.Bold)
            }
        }
        
        if let underlined = input.underlined {
            if underlined{
                newFormatters.insert(.Underline)
            } else {
                newFormatters.remove(.Underline)
            }
        }
        
        if let strikethrough = input.strikethrough {
            if strikethrough {
                newFormatters.insert(.Strikethrough)
            } else {
                newFormatters.remove(.Strikethrough)
            }
        }
        
        if let obfuscated = input.obfuscated {
            if obfuscated {
                newFormatters.insert(.Obfuscated)
            } else {
                newFormatters.remove(.Obfuscated)
            }
        }
        
        if let italic = input.italic {
            if italic {
                newFormatters.insert(.Italic)
            } else {
                newFormatters.remove(.Italic)
            }
        }
        
        var currentMotdColor = color
        if let newColor = input.color {
            if let motdColor = javaJsonColorFormats[newColor] {
                currentMotdColor = motdColor.rawValue
            } else if newColor.contains("#") {
                currentMotdColor = newColor
            }
        }
        
        
        if let motdText = input.text, !motdText.isEmpty {
            // current peice of json segment has text data, so add modifiers and then we can append any extras that may exist recursively.
            let section = FormattedMOTDSection()
            section.text = motdText
            section.formatters = newFormatters
            section.color = currentMotdColor
            response.append(section)
        }
        
        input.extra?.forEach({ extraSection in
            response.append(contentsOf: parseJavaMOTD(input: extraSection, color: currentMotdColor, formatters: newFormatters))
        })
        
        return response
    }
    
    
    
    static let javaSectionSignFormatCodes = [
        "k": MOTDFormatter.Obfuscated,
        "l": MOTDFormatter.Bold,
        "m": MOTDFormatter.Strikethrough,
        "n": MOTDFormatter.Underline,
        "o": MOTDFormatter.Italic,
        "r": MOTDFormatter.Reset
    ]

    static let javaSectionSignColorFormats = [
        "0": MOTDColor.Black,
        "1": MOTDColor.DarkBlue,
        "2": MOTDColor.DarkGreen,
        "3": MOTDColor.DarkAqua,
        "4": MOTDColor.DarkRed,
        "5": MOTDColor.DarkPurple,
        "6": MOTDColor.Gold,
        "7": MOTDColor.Gray,
        "8": MOTDColor.DarkGray,
        "9": MOTDColor.Blue,
        "a": MOTDColor.Green,
        "b": MOTDColor.Aqua,
        "c": MOTDColor.Red,
        "d": MOTDColor.LightPurple,
        "e": MOTDColor.Yellow,
        "f": MOTDColor.White
    ]

    static let javaJsonColorFormats = [
        "black": MOTDColor.Black,
        "dark_blue": MOTDColor.DarkBlue,
        "dark_green": MOTDColor.DarkGreen,
        "dark_aqua": MOTDColor.DarkAqua,
        "dark_red": MOTDColor.DarkRed,
        "dark_purple": MOTDColor.DarkPurple,
        "gold": MOTDColor.Gold,
        "gray": MOTDColor.Gray,
        "dark_gray": MOTDColor.DarkGray,
        "blue": MOTDColor.Blue,
        "green": MOTDColor.Green,
        "aqua": MOTDColor.Aqua,
        "red": MOTDColor.Red,
        "light_purple": MOTDColor.LightPurple,
        "yellow": MOTDColor.Yellow,
        "white": MOTDColor.White
    ]


}




