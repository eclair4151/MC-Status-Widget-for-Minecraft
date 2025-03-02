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
    
    var body: some View {
        ServerList()
            .modelContainer(SwiftDataHelper.getModelContainter())
    }
}
