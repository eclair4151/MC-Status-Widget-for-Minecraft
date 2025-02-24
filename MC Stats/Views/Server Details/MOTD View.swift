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
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading) // Make the Text view full width
                .cornerRadius(15)
        }
    }
}

//#Preview {
//    MOTDView()
//}
