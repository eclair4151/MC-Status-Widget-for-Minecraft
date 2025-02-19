import SwiftUI
import Charts

struct PingGraph: View {
    @Binding private var data: [ServerPing]
    
    init(_ data: Binding<[ServerPing]>) {
        _data = data
    }
    
    private let detailChartHeight = 300.0
    
    @State private var lineWidth = 2.0
    @State private var chartColor: Color = .blue
    @State private var showSymbols = true
    
    @State private var selectedElement: ServerPing? = nil
    
    @State private var showLollipop = true
    
    var average: Double {
        data.map {
            Double($0.ping)
        }
        .reduce(0, +) / Double(data.count)
    }
    
    var body: some View {
        List {
            chart
            
            Section {
                Text("**Hold and drag** over the chart to view and move the lollipop")
                    .callout()
                
                Toggle("Lollipop", isOn: $showLollipop)
                                
                Text("Average: \(average)")
                
                Button("Clear") {
                    selectedElement = nil
                    data.removeAll()
                }
            }
        }
    }
    
    private var chart: some View {
        Chart(data) {
            RuleMark(y: .value("Avg.", average))
                .opacity(0.1)
                .lineStyle(StrokeStyle(lineWidth: 1))
                .foregroundStyle(.red)
            
            LineMark (
                x: .value("Date", $0.date),
                y: .value("Ping", $0.ping)
            )
            .accessibilityLabel($0.date.formatted(date: .complete, time: .omitted))
            .accessibilityValue("\($0.ping) ping")
            .lineStyle(StrokeStyle(lineWidth: lineWidth))
            .foregroundStyle(chartColor.gradient)
            .interpolationMethod(.cardinal)
            .symbol(Circle().strokeBorder(lineWidth: lineWidth))
            .symbolSize(showSymbols ? 60 : 0)
        }
        .chartYScale(domain: 0...300)
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle()
                    .fill(.clear)
                    .contentShape(.rect())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                let element = findElement(
                                    location: value.location,
                                    proxy: proxy,
                                    geo: geo
                                )
                                
                                if selectedElement?.date == element?.date {
                                    // If tapping the same element, clear the selection
                                    selectedElement = nil
                                } else {
                                    selectedElement = element
                                }
                            }
                            .exclusively (
                                before: DragGesture()
                                    .onChanged { value in
                                        selectedElement = findElement(location: value.location, proxy: proxy, geo: geo)
                                    }
                            )
                    )
            }
        }
        .chartBackground { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    if showLollipop, let selectedElement {
                        let startPositionX1 = proxy.position(forX: selectedElement.date) ?? 0
                        
                        let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                        let lineHeight = geo[proxy.plotAreaFrame].maxY
                        let boxWidth: CGFloat = 70
                        let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
                        
                        Rectangle()
                            .fill(.red)
                            .frame(width: 2, height: lineHeight)
                            .position(x: lineX, y: lineHeight / 2)
                        
                        VStack(alignment: .center) {
                            // Text("\(selectedElement.date, format: .dateTime.year().month().day())")
                            
                            Text("\(selectedElement.date, format: .dateTime.hour().minute().second())")
                                .callout()
                                .foregroundStyle(.secondary)
                            
                            Text("\(selectedElement.ping, format: .number)")
                                .title2(.bold)
                                .foregroundColor(.primary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityHidden(false)
                        .frame(width: boxWidth, alignment: .leading)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.background)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.quaternary.opacity(0.7))
                            }
                            .padding(.horizontal, -8)
                            .padding(.vertical, -4)
                        }
                        .offset(x: boxOffset)
                    }
                }
            }
        }
        .chartXAxis(.automatic)
        .chartYAxis(.automatic)
        .frame(height: detailChartHeight)
        .animation(.default, value: data.count)
    }
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geo: GeometryProxy) -> ServerPing? {
        let relativeXPosition = location.x - geo[proxy.plotAreaFrame].origin.x
        
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            
            for salesDataIndex in data.indices {
                let nthSalesDataDistance = data[salesDataIndex].date.distance(to: date)
                
                if abs(nthSalesDataDistance) < minDistance {
                    minDistance = abs(nthSalesDataDistance)
                    index = salesDataIndex
                }
            }
            
            if let index {
                return data[index]
            }
        }
        
        return nil
    }
}

#Preview {
    @Previewable @State var pings = (0..<20).map {
        ServerPing(Int.random(in: 10...100), date: Date().addingTimeInterval(Double($0 * 31536000)))
    }
    
    PingGraph($pings)
}
