import SwiftUI

extension EditServerView {
    // server domains cannot have / or :
    func isUrlValid(_ url: String) -> Bool {
        !url.contains(":") && !url.contains("/")
    }
    
    func saveDisabled() -> Bool {
        tempNameInput.isEmpty || tempServerInput.isEmpty
    }
    
    func inputHasChanged() -> Bool {
        tempNameInput != server.name ||
        tempServerInput != server.serverUrl ||
        (tempPortInput ?? 0) != server.serverPort
    }
    
    func extractPort(_ text: String) {
        // Check if text contains a colomn
        if let colonIndex = text.firstIndex(of: ":") {
            // Extract the port number after the colon
            let portValue = text[text.index(after: colonIndex)...]
            let port = String(portValue)
            
            // Remove the port from serverIP if necessary
            let serverIP = String(text[..<colonIndex])
            tempServerInput = serverIP
            tempPortInput = Int(port)
        }
    }
    
    // CALLED WHEN A SERVER IS EDITED OR ADDED
    func saveItem() {
        // first validate url doesnt contains any / or :
        tempServerInput = tempServerInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !isUrlValid(tempServerInput) {
            showingInvalidUrlAlert = true
            return
        }
        
        tempNameInput = tempNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if tempNameInput.isEmpty {
            showingInvalidNameAlert = true
            return
        }
        
        if let tempPortInput,tempPortInput < 0 || tempPortInput > 65535 {
            showingInvalidPortAlert = true
            return
        }
        
        withAnimation {
            server.serverUrl = tempServerInput
            
            if let tempPortInput {
                server.serverPort = tempPortInput
                
            } else if tempServerType == .Java {
                server.serverPort = 25565
                
            } else if tempServerType == .Bedrock {
                server.serverPort = 19132
            }
            
            server.name = tempNameInput
            server.serverType = tempServerType
            server.srvServerUrl = ""
            server.srvServerPort = 0
            modelContext.insert(server)
            
            do {
                try modelContext.save()
            } catch {
                print(error.localizedDescription)
            }
            
            print("Added server")
            
            ShortcutsProvider.updateAppShortcutParameters()
            
            refresh()
            refreshAllWidgets()
            
            dismiss()
        }
    }
}
