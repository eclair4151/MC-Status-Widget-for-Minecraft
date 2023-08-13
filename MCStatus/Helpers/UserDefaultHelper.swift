//
//  UserDefaultHelper.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 8/6/23.
//

import Foundation

class UserDefaultHelper {
    
    
    static func SRVEnabled() -> Bool {
        return true
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
