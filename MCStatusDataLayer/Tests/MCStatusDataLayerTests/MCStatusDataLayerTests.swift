import Testing
import Foundation

@testable import MCStatusDataLayer

struct MCParsingTests {
    @Test func testParsing() throws {
        let stringInput = #"""
        {
            "description": {
            "text": "",
            "extra":
                [
                    {
                        "text": "                Vanilla Realms",
                        "color": "light_purple",
                        "bold": true
                    },
                    "\n",
                    {
                        "text": "             ",
                        "color": "white"
                    },
                    {
                        "text": "⛏ ",
                        "color": "dark_red"
                    },
                    {
                        "text": "Friendly 1.20 Survival! ",
                        "color": "white"
                    },
                    {
                        "text": "⛏",
                        "color": "dark_red"
                    }
                ]
            }
        }
        """#
        
        let jsonData = stringInput.data(using: .utf8)
        
        guard let jsonData else {
            throw ServerStatusCheckerError.StatusUnparsable
        }
        
        var responseObject: JavaServerStatusResponse
        
        do {
            //attempt to parse it into a json using a custom parser defined in the object
            responseObject = try JSONDecoder().decode(JavaServerStatusResponse.self, from: jsonData)
        } catch let error {
            print("Unable to parse response from input: " + stringInput)
            throw error
        }
        
        print(responseObject.version?.name ?? "unknown")
    }
}
