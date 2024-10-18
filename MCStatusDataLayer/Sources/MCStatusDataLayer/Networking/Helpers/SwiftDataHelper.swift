//
//  SwiftUIHelper.swift
//  MC Status
//
//  Created by Tomer Shemesh on 8/13/23.
//

import Foundation
import SwiftData

// random helper function
public class SwiftDataHelper {
    public static func getModelContainter() -> ModelContainer {

        if (UserDefaultHelper.shared.get(for: .iCloudEnabled, defaultValue: true)) {
            do {
                let config = ModelConfiguration(nil, schema: Schema ([SavedMinecraftServer.self]), isStoredInMemoryOnly: false, allowsSave: true, groupContainer: ModelConfiguration.GroupContainer.identifier("group.shemeshapps.MinecraftServerStatus"), cloudKitDatabase: ModelConfiguration.CloudKitDatabase.private("iCloud.com.shemeshapps.MinecraftServerStatus"))
                return try ModelContainer(for: SavedMinecraftServer.self, configurations: config)
            } catch {
                // something broken with icloud? continue with local container without config.
                print("ERROR LOADING ICLOUD MODEL CONTAINTER: " + error.localizedDescription)
            }
       }
        
        // if this is broken then something is f'ed up. just crash
        return try! ModelContainer(for: SavedMinecraftServer.self)
    }
    
    public static func getSavedServersBg(container: ModelContainer) -> [SavedMinecraftServer] {
        let modelContext = ModelContext(container)
        
        let fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: nil,
            sortBy: [.init(\.displayOrder)]
        )
        guard let results = try? modelContext.fetch(fetch) else {
            return []
        }
        
        return results
    }
    
    
    @MainActor
    public static func getSavedServers(container: ModelContainer) -> [SavedMinecraftServer] {
        let modelContext = container.mainContext
        
        let fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: nil,
            sortBy: [.init(\.displayOrder)]
        )
        guard let results = try? modelContext.fetch(fetch) else {
            return []
        }
        
        return results
    }
    
    @MainActor 
    public static func getSavedServerById(container: ModelContainer, server_id: UUID) -> SavedMinecraftServer? {
        let modelContext = container.mainContext

        let serverPredicate = #Predicate<SavedMinecraftServer> {
            $0.id == server_id
        }
        
        var fetch = FetchDescriptor<SavedMinecraftServer>(
            predicate: serverPredicate,
            sortBy: [.init(\.displayOrder)]
        )
        fetch.fetchLimit = 1
        
        guard let results = try? modelContext.fetch(fetch) else {
            return nil
        }
        
        guard results.count > 0 else {
            return nil
        }
        return results.first
    }
    
}











//@State private var isShowPhotoLibrary = false
//
//    .sheet(isPresented: $isShowPhotoLibrary) {
//        ImagePicker(sourceType: .photoLibrary)
//    }
//
//struct ImagePicker: UIViewControllerRepresentable {
//
//    var sourceType: UIImagePickerController.SourceType = .photoLibrary
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
//
//        let imagePicker = UIImagePickerController()
//        imagePicker.allowsEditing = true
//        imagePicker.sourceType = sourceType
//
//        return imagePicker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
//
//    }
//}



//import WidgetKit
//
//extension WidgetCenter {
//    func currentConfigurations() async -> [WidgetInfo] {
//        try await withCheckedThrowingContinuation { continuation in
//            getCurrentConfigurations { result in
//                continuation.resume(with: result)
//            }
//        }
//    }
//}
