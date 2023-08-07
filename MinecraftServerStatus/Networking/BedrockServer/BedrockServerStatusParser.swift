//
//  BedrockServerStatusParser.swift
//  MinecraftServerStatus
//
//  Created by Tomer Shemesh on 8/2/23.
//

import Foundation

class BedrockServerStatusParser: ServerStatusParserProtocol {
    static func parseServerResponse(stringInput: String) throws -> ServerStatus {
        let dataParts = stringInput.split(separator: ";")
        //[edition, motdLine1, protocolVersion, version, onlinePlayers, maxPlayers, serverID, motdLine2, gameMode, gameModeID, portIPv4, portIPv6]

        guard dataParts.count > 7 else {
            throw ServerStatusCheckerError.StatusUnparsable
        }

        let serverStatus = ServerStatus()
        // parse both lines seperately, because all formatting is reset for the second line on Bedrock
        // need to insert the newline manually
        var formattedMessageSections = parseBedrockMOTD(input: String(dataParts[1]))
        formattedMessageSections.append(FormattedMOTDSection(text: "\n"))
        formattedMessageSections.append(contentsOf: parseBedrockMOTD(input: String(dataParts[7])))
        
        serverStatus.description = FormattedMOTD(messageSections: formattedMessageSections)
        serverStatus.onlinePlayerCount = Int(dataParts[4]) ?? 0
        serverStatus.maxPlayerCount = Int(dataParts[5]) ?? 0
        serverStatus.version = String(dataParts[3])
        serverStatus.status = .Online
        return serverStatus
    }
    
    
    // § is a section-sign which is used for formatting legacy style MOTD and bedrock
    // https://minecraft.fandom.com/wiki/Formatting_codes
    //Idealy, i would have the same code for both java and bedrock MOTD parsing, but alas there are some subtle differences in the parsing code that make it just annoying enough to require breaking into 2 seperate functions (See other parser in JavaServerStatusParser.
    static func parseBedrockMOTD(input: String) -> [FormattedMOTDSection] {
        
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
                if let sectionFormatter = bedrockSectionSignFormatCodes[String(modifierKey)] {
                    // cap off current section, so next set can have new formatters.
                    // if the text is empty dont bother adding it
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
                } else if let colorFormatter = bedrockSectionSignColorFormats[String(modifierKey)] {
                    // if the text is empty dont both adding it
                    if (!currentSection.text.isEmpty) {
                        motdSections.append(currentSection)
                    }
                    // in bedrock edition only, when a new color is specified, formatters are passed to the following section
                    let newSection = FormattedMOTDSection()
                    newSection.color = colorFormatter.rawValue
                    newSection.formatters = currentSection.formatters
                    currentSection = newSection
                }
            } else {
                currentSection.text.append(input[currentIndex])
            }
            
            // Manually increment the index
            currentIndex = input.index(after: currentIndex)
        }
        
        return motdSections
    }
    
    
    
    
    static let bedrockSectionSignFormatCodes = [
        "k": MOTDFormatter.Obfuscated,
        "l": MOTDFormatter.Bold,
        "o": MOTDFormatter.Italic,
        "r": MOTDFormatter.Reset
    ]

    static let bedrockSectionSignColorFormats = [
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
        "f": MOTDColor.White,
        "g": MOTDColor.MinecoinGold,
        "h": MOTDColor.MaterialQuartz,
        "i": MOTDColor.MaterialIron,
        "j": MOTDColor.MaterialNetherite,
        "m": MOTDColor.MaterialRedstone,
        "n": MOTDColor.MaterialCopper,
        "p": MOTDColor.MaterialGold,
        "q": MOTDColor.MaterialEmerald,
        "s": MOTDColor.MaterialDiamond,
        "t": MOTDColor.MaterialLapis,
        "u": MOTDColor.MaterialAmethyst
    ]
}
