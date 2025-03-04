import SwiftUI
import SwiftData
import MCStatsDataLayer

struct NavContainer: View {
    @State private var vm: MessagesVM
    @Binding private var vc: MessagesViewController?
    
    init(_ vc: Binding<MessagesViewController?>) {
        _vc = vc
        self.vm = .init(vc.wrappedValue)
    }
    
    @State private var fullScreen = false
    
    var body: some View {
        VStack {
            Text("Full-screen only")
            
            Button("Open in full screen") {
                fullScreen = true
            }
        }
        .fullScreenCover(isPresented: $fullScreen) {
            ServerList()
                .modelContainer(SwiftDataHelper.getModelContainter())
        }
    }
}
