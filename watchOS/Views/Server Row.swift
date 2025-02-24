import SwiftUI
import MCStatsDataLayer
import Nuke
import NukeUI

struct ServerRow: View {
    private var vm: ServerStatusVM
    
    init(_ vm: ServerStatusVM) {
        self.vm = vm
    }
    
    var body: some View {
        HStack {
            Image(uiImage: vm.serverIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .cornerRadius(5)
                .background(Color.serverIconBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(hex: "6e6e6e"), lineWidth: 3)
                }
                .clipShape(.rect(cornerRadius: 5))
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 0) {
                if let status = vm.status {
                    Text(vm.server.name)
                        .bold()
                        .minimumScaleFactor(0.65)
                        .lineLimit(1)
                    
                    HStack {
                        Text(status.getWatchDisplayText())
                            .footnote()
                            .foregroundStyle((status.status == .Offline) ? .red : .primary)
                        
                        if vm.loadingStatus == .Loading {
                            ProgressView()
                                .frame(width: 15, height: 15)
                                .scaleEffect(CGSize(width: 0.65, height: 0.65), anchor: .center)
                        }
                    }
                } else {
                    HStack {
                        Text(vm.server.name)
                            .bold()
                            .minimumScaleFactor(0.65)
                            .lineLimit(1)
                        
                        ProgressView()
                            .frame(width: 20, height: 20)
                            .scaleEffect(CGSize(width: 0.8, height: 0.8), anchor: .center)
                    }
                }
                
                CustomProgressView(progress: vm.getPlayerCountPercentage())
                    .frame(height:6)
                    .padding(.vertical, 3)
            }
        }
    }
}

//#Preview {
////    ServerRowView(title: "test", subtitle: "subtitle")
////    let vm = ServerStatusVM(modelContext: , server: <#T##SavedMinecraftServer#>)
//}
