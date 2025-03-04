import SwiftUI
import MCStatsDataLayer

struct MOTDView: View {
    private let status: ServerStatus?
    
    init(_ status: ServerStatus?) {
        self.status = status
    }
    
    var body: some View {
        if let status, let _ = status.description {
            status.generateMOTDView()
                .shadow(radius: 5)
                .padding(10)
                .frame(maxWidth: .infinity)
                .cornerRadius(15)
        }
    }
}

//#Preview {
//    MOTDView()
//}
