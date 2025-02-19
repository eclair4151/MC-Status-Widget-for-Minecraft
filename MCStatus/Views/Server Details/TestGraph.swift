import SwiftUI
import Charts

struct SingleLineLollipop: View {
    @State private var lineWidth = 2.0
    @State private var interpolationMethod: ChartInterpolationMethod = .cardinal
    @State private var chartColor: Color = .blue
    @State private var showSymbols = true
    @State private var selectedElement: Sale? = SalesData.last30Days[10]
    @State private var showLollipop = true
    
    var data = SalesData.last30Days
    
    var body: some View {
        List {
            Section {
                chart
            }
            
            Section {
                Text("**Hold and drag** over the chart to view and move the lollipop")
                    .callout()
                Toggle("Lollipop", isOn: $showLollipop)
            }
        }
        //            .navigationBarTitle(ChartType.singleLineLollipop.title, displayMode: .inline)
    }
    
    private var chart: some View {
        Chart(data, id: \.day) {
            LineMark (
                x: .value("Date", $0.day),
                y: .value("Sales", $0.sales)
            )
            .accessibilityLabel($0.day.formatted(date: .complete, time: .omitted))
            .accessibilityValue("\($0.sales) sold")
            .lineStyle(StrokeStyle(lineWidth: lineWidth))
            .foregroundStyle(chartColor.gradient)
            .interpolationMethod(interpolationMethod.mode)
            .symbol(Circle().strokeBorder(lineWidth: lineWidth))
            .symbolSize(showSymbols ? 60 : 0)
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture (
                        SpatialTapGesture()
                            .onEnded { value in
                                let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                                if selectedElement?.day == element?.day {
                                    // If tapping the same element, clear the selection.
                                    selectedElement = nil
                                } else {
                                    selectedElement = element
                                }
                            }
                            .exclusively (
                                before: DragGesture()
                                    .onChanged { value in
                                        selectedElement = findElement(location: value.location, proxy: proxy, geometry: geo)
                                    }
                            )
                    )
            }
        }
        .chartBackground { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    if showLollipop,
                       let selectedElement {
                        let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedElement.day)!
                        let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
                        
                        let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                        let lineHeight = geo[proxy.plotAreaFrame].maxY
                        let boxWidth: CGFloat = 100
                        let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
                        
                        Rectangle()
                            .fill(.red)
                            .frame(width: 2, height: lineHeight)
                            .position(x: lineX, y: lineHeight / 2)
                        
                        VStack(alignment: .center) {
                            Text("\(selectedElement.day, format: .dateTime.year().month().day())")
                                .callout()
                                .foregroundStyle(.secondary)
                            Text("\(selectedElement.sales, format: .number)")
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
        //        .accessibilityChartDescriptor(self)
        .frame(height: Constants.detailChartHeight)
    }
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> Sale? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            
            for salesDataIndex in data.indices {
                let nthSalesDataDistance = data[salesDataIndex].day.distance(to: date)
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
        ServerPing(Int.random(in: 10...100), date: Date().addingTimeInterval(Double($0)))
    }
    
//    PingGraph($pings)
    SingleLineLollipop()
}

// MARK: - Accessibility
//extension SingleLineLollipop: AXChartDescriptorRepresentable {
//    func makeChartDescriptor() -> AXChartDescriptor {
//        AccessibilityHelpers.chartDescriptor(forSalesSeries: data)
//    }
//}

import Charts

enum ChartInterpolationMethod: Identifiable, CaseIterable {
    case linear
    case monotone
    case catmullRom
    case cardinal
    case stepStart
    case stepCenter
    case stepEnd
    
    var id: String {
        mode.description
    }
    
    var mode: InterpolationMethod {
        switch self {
        case .linear:
            return .linear
        case .monotone:
            return .monotone
        case .stepStart:
            return .stepStart
        case .stepCenter:
            return .stepCenter
        case .stepEnd:
            return .stepEnd
        case .catmullRom:
            return .catmullRom
        case .cardinal:
            return .cardinal
        }
    }
}

enum SalesData {
    /// Sales by day for the last 30 days.
    static let last30Days = [
        (day: date(year: 2022, month: 5, day: 8), sales: 168),
        (day: date(year: 2022, month: 5, day: 9), sales: 117),
        (day: date(year: 2022, month: 5, day: 10), sales: 106),
        (day: date(year: 2022, month: 5, day: 11), sales: 119),
        (day: date(year: 2022, month: 5, day: 12), sales: 109),
        (day: date(year: 2022, month: 5, day: 13), sales: 104),
        (day: date(year: 2022, month: 5, day: 14), sales: 196),
        (day: date(year: 2022, month: 5, day: 15), sales: 172),
        (day: date(year: 2022, month: 5, day: 16), sales: 122),
        (day: date(year: 2022, month: 5, day: 17), sales: 115),
        (day: date(year: 2022, month: 5, day: 18), sales: 138),
        (day: date(year: 2022, month: 5, day: 19), sales: 110),
        (day: date(year: 2022, month: 5, day: 20), sales: 106),
        (day: date(year: 2022, month: 5, day: 21), sales: 187),
        (day: date(year: 2022, month: 5, day: 22), sales: 187),
        (day: date(year: 2022, month: 5, day: 23), sales: 119),
        (day: date(year: 2022, month: 5, day: 24), sales: 160),
        (day: date(year: 2022, month: 5, day: 25), sales: 144),
        (day: date(year: 2022, month: 5, day: 26), sales: 152),
        (day: date(year: 2022, month: 5, day: 27), sales: 148),
        (day: date(year: 2022, month: 5, day: 28), sales: 240),
        (day: date(year: 2022, month: 5, day: 29), sales: 242),
        (day: date(year: 2022, month: 5, day: 30), sales: 173),
        (day: date(year: 2022, month: 5, day: 31), sales: 143),
        (day: date(year: 2022, month: 6, day: 1), sales: 137),
        (day: date(year: 2022, month: 6, day: 2), sales: 123),
        (day: date(year: 2022, month: 6, day: 3), sales: 146),
        (day: date(year: 2022, month: 6, day: 4), sales: 214),
        (day: date(year: 2022, month: 6, day: 5), sales: 250),
        (day: date(year: 2022, month: 6, day: 6), sales: 146)
    ].map { Sale(day: $0.day, sales: $0.sales) }
    
    /// Total sales for the last 30 days.
    static var last30DaysTotal: Int {
        last30Days.map { $0.sales }.reduce(0, +)
    }
    
    static var last30DaysAverage: Double {
        Double(last30DaysTotal / last30Days.count)
    }
    
    /// Sales by month for the last 12 months.
    static let last12Months = [
        (month: date(year: 2021, month: 7), sales: 3952, dailyAverage: 127, dailyMin: 95, dailyMax: 194),
        (month: date(year: 2021, month: 8), sales: 4044, dailyAverage: 130, dailyMin: 96, dailyMax: 189),
        (month: date(year: 2021, month: 9), sales: 3930, dailyAverage: 131, dailyMin: 101, dailyMax: 184),
        (month: date(year: 2021, month: 10), sales: 4217, dailyAverage: 136, dailyMin: 96, dailyMax: 193),
        (month: date(year: 2021, month: 11), sales: 4006, dailyAverage: 134, dailyMin: 104, dailyMax: 202),
        (month: date(year: 2021, month: 12), sales: 3994, dailyAverage: 129, dailyMin: 96, dailyMax: 190),
        (month: date(year: 2022, month: 1), sales: 4202, dailyAverage: 136, dailyMin: 96, dailyMax: 203),
        (month: date(year: 2022, month: 2), sales: 3749, dailyAverage: 134, dailyMin: 98, dailyMax: 200),
        (month: date(year: 2022, month: 3), sales: 4329, dailyAverage: 140, dailyMin: 104, dailyMax: 218),
        (month: date(year: 2022, month: 4), sales: 4084, dailyAverage: 136, dailyMin: 93, dailyMax: 221),
        (month: date(year: 2022, month: 5), sales: 4559, dailyAverage: 147, dailyMin: 104, dailyMax: 242),
        (month: date(year: 2022, month: 6), sales: 1023, dailyAverage: 170, dailyMin: 120, dailyMax: 250)
    ]
    
    /// Total sales for the last 12 months.
    static var last12MonthsTotal: Int {
        last12Months.map { $0.sales }.reduce(0, +)
    }
    
    static var last12MonthsDailyAverage: Int {
        last12Months.map { $0.dailyAverage }.reduce(0, +) / last12Months.count
    }
}

struct Sale {
    let day: Date
    var sales: Int
}

func date(year: Int, month: Int, day: Int = 1, hour: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minutes, second: seconds)) ?? Date()
}

enum Constants {
    static let previewChartHeight: CGFloat = 100
    static let detailChartHeight: CGFloat = 300
}

//enum AccessibilityHelpers {
//    // TODO: This should be a protocol but since the data objects are in flux this will suffice
//    static func chartDescriptor(forSalesSeries data: [Sale],
//                                saleThreshold: Double? = nil,
//                                isContinuous: Bool = false) -> AXChartDescriptor {
//
//        // Since we're measuring a tangible quantity,
//        // keeping an independant minimum prevents visual scaling in the Rotor Chart Details View
//        let min = 0 // data.map(\.sales).min() ??
//        let max = data.map(\.sales).max() ?? 0
//
//        // A closure that takes a date and converts it to a label for axes
//        let dateTupleStringConverter: ((Sale) -> (String)) = { dataPoint in
//
//            let dateDescription = dataPoint.day.formatted(date: .complete, time: .omitted)
//
//            if let threshold = saleThreshold {
//                let isAbove = dataPoint.isAbove(threshold: threshold)
//
//                return "\(dateDescription): \(isAbove ? "Above" : "Below") threshold"
//            }
//
//            return dateDescription
//        }
//
//        let xAxis = AXNumericDataAxisDescriptor(
//            title: "Date index",
//            range: Double(0)...Double(data.count),
//            gridlinePositions: []
//        ) { "Day \(Int($0) + 1)" }
//
//        let yAxis = AXNumericDataAxisDescriptor(
//            title: "Sales",
//            range: Double(min)...Double(max),
//            gridlinePositions: []
//        ) { value in "\(Int(value)) sold" }
//
//        let series = AXDataSeriesDescriptor(
//            name: "Daily sale quantity",
//            isContinuous: isContinuous,
//            dataPoints: data.enumerated().map { (idx, point) in
//                    .init(x: Double(idx),
//                          y: Double(point.sales),
//                          label: dateTupleStringConverter(point))
//            }
//        )
//
//        return AXChartDescriptor(
//            title: "Sales per day",
//            summary: nil,
//            xAxis: xAxis,
//            yAxis: yAxis,
//            additionalAxes: [],
//            series: [series]
//        )
//    }
//
//    static func chartDescriptor(forLocationSeries data: [LocationData.Series]) -> AXChartDescriptor {
//        let dateStringConverter: ((Date) -> (String)) = { date in
//            date.formatted(date: .abbreviated, time: .omitted)
//        }
//
//        // Create a descriptor for each Series object
//        // as that allows auditory comparison with VoiceOver
//        // much like the chart does visually and allows individual city charts to be played
//        let series = data.map { dataPoint in
//            AXDataSeriesDescriptor(
//                name: "\(dataPoint.city)",
//                isContinuous: false,
//                dataPoints: dataPoint.sales.map { data in
//                        .init(x: dateStringConverter(data.weekday),
//                              y: Double(data.sales),
//                              label: "\(data.weekday.weekdayString)")
//                }
//            )
//        }
//
//        // Get the minimum/maximum within each city
//        // and then the limits of the resulting list
//        // to pass in as the Y axis limits
//        let limits: [(Int, Int)] = data.map { seriesData in
//            let sales = seriesData.sales.map { $0.sales }
//            let localMin = sales.min() ?? 0
//            let localMax = sales.max() ?? 0
//            return (localMin, localMax)
//        }
//
//        let min = limits.map { $0.0 }.min() ?? 0
//        let max = limits.map { $0.1 }.max() ?? 0
//
//        // Get the unique days to mark the x-axis
//        // and then sort them
//        let uniqueDays = Set( data
//            .map { $0.sales.map { $0.weekday } }
//            .joined() )
//        let days = Array(uniqueDays).sorted()
//
//        let xAxis = AXCategoricalDataAxisDescriptor(
//            title: "Days",
//            categoryOrder: days.map { dateStringConverter($0) }
//        )
//
//        let yAxis = AXNumericDataAxisDescriptor(
//            title: "Sales",
//            range: Double(min)...Double(max),
//            gridlinePositions: []
//        ) { value in "\(Int(value)) sold" }
//
//        return AXChartDescriptor(
//            title: "Sales per day",
//            summary: nil,
//            xAxis: xAxis,
//            yAxis: yAxis,
//            additionalAxes: [],
//            series: series
//        )
//    }
//}
