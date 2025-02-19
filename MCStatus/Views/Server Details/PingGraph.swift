import SwiftUI
import Charts

struct PingGraph: View {
    @Binding private var pings: [ServerPing]
    
    init(_ pings: Binding<[ServerPing]>) {
        _pings = pings
    }
    @State private var lineWidth = 2.0
//    @State private var interpolationMethod: ChartInterpolationMethod = .cardinal
    @State private var chartColor: Color = .blue
    @State private var showSymbols = true

    @State private var selectedPing: ServerPing?
    @State private var showLollipop = true
    
    var body: some View {
        List {
            Chart(pings) {
                LineMark(
                    x: .value("Date", $0.date),
                    y: .value("Ping", $0.ping)
                )
                .accessibilityLabel($0.date.formatted(date: .complete, time: .omitted))
                .accessibilityValue("\($0.ping) sold")
                .lineStyle(StrokeStyle(lineWidth: lineWidth))
                .foregroundStyle(chartColor.gradient)
                .interpolationMethod(.cardinal)
                .symbol(Circle().strokeBorder(lineWidth: lineWidth))
                .symbolSize(showSymbols ? 60 : 0)
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                                    selectedPing = selectedPing?.id == element?.id ? nil : element
                                }
                                .exclusively(
                                    before: DragGesture()
                                        .onChanged { value in
                                            selectedPing = findElement(location: value.location, proxy: proxy, geometry: geo)
                                        }
                                )
                        )
                }
            }
            .chartBackground { proxy in
                if showLollipop, let selectedPing {
                    GeometryReader { geo in
                        let xPos = proxy.position(forX: selectedPing.date) ?? 0
                        let lineX = xPos + geo[proxy.plotAreaFrame].origin.x
                        let lineHeight = geo[proxy.plotAreaFrame].maxY
                        let boxWidth: CGFloat = 100
                        let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
                        
                        ZStack {
                            Rectangle()
                                .fill(.red)
                                .frame(width: 2, height: lineHeight)
                                .position(x: lineX, y: lineHeight / 2)
                            
                            VStack {
                                Text(selectedPing.date, format: .dateTime.hour().minute().second())
                                    .callout()
                                    .foregroundStyle(.secondary)
                                Text("\(selectedPing.ping) ms")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                            }
                            .frame(width: boxWidth)
                            .background {
                                RoundedRectangle(cornerRadius: 8).fill(.background).shadow(radius: 2)
                            }
                            .offset(x: boxOffset)
                        }
                    }
                }
            }
            .chartXAxis(.automatic)
            .chartYAxis(.automatic)
            .frame(height: 200)
        }
    }
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> ServerPing? {
        let relativeX = location.x - geometry[proxy.plotAreaFrame].origin.x
        
        if let date = proxy.value(atX: relativeX) as Date? {
            return pings.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
        }
        
        return nil
    }
}

#Preview {
    @Previewable @State var pings = (0..<20).map {
        ServerPing(Int.random(in: 10...100), date: Date().addingTimeInterval(Double($0)))
    }
    
    PingGraph($pings)
}
