import SwiftUI
import MCStatusDataLayer

struct ServerRowView: View {
    var vm: ServerStatusVM
    
    var body: some View {
        HStack {
            Image(uiImage: vm.serverIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 65, height: 65)
                .cornerRadius(8)
                .background(Color.serverIconBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "6e6e6e"), lineWidth: 3)
                }
                .clipShape(.rect(cornerRadius: 8))
                .padding([.trailing], 5)
            
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(vm.server.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let status = vm.status {
                            if status.status == .Offline {
                                Text(status.status.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .bold()
                            } else {
                                Text(status.getDisplayText())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                        } else if vm.loadingStatus == .Loading {
                            Text(vm.loadingStatus.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if vm.loadingStatus == .Loading {
                        ProgressView()
                            .padding(.trailing, 5)
                    }
                }
                CustomProgressView(progress: CGFloat(vm.getPlayerCountPercentage()))
                    .frame(height: 8)
                
                if UserDefaultHelper.shared.get(for: .showUsersOnHomesreen, defaultValue: true) {
                    let sampletext = vm.getUserSampleText()
                    
                    Text(sampletext)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(0)
                        .frame(height:8)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
    }
}

//#Preview {
////    ServerRowView(title: "test", subtitle: "subtitle")
////    let vm = ServerStatusVM(modelContext: , server: <#T##SavedMinecraftServer#>)
//}
