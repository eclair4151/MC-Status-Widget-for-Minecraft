import SwiftUI

struct FeatureRow: View {
    private let feature: Feature
    
    init(_ feature: Feature) {
        self.feature = feature
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: feature.icon)
                .foregroundColor(feature.iconColor)
                .imageScale(.large)
                .scaledToFit()
                .frame(width: 25, height: 25)
            
            VStack(alignment: .leading) {
                Text(feature.title)
                    .headline(.bold)
                
                Text(feature.description)
                    .secondary()
            }
        }
    }
}
