import SwiftUI

struct CustomProgressView: View {
    var progress: CGFloat
    var bgColor = Color.gray
    var bgOpactiy = 1.0
    var filledColor = Color.green
    
    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let width = geo.size.width
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(bgColor)
                    .frame(width: width, height: height)
                    .cornerRadius(height / 2)
                    .opacity(bgOpactiy)
                
                Rectangle()
                    .foregroundColor(filledColor)
                    .frame(width: width * progress, height: height)
                    .cornerRadius(height / 2)
                    .animation(.easeInOut(duration: 0.5), value: progress)
                    .widgetAccentable()
            }
        }
    }
}
