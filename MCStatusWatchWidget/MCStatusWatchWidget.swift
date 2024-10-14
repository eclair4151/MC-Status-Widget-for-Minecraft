////
////  MCStatusWatchWidget.swift
////  MCStatusWatchWidget
////
////  Created by Tomer Shemesh on 10/13/24.
////
//
//import WidgetKit
//import SwiftUI
//
//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), emoji: "😀")
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), emoji: "😀")
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, emoji: "😀")
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//
////    func relevances() async -> WidgetRelevances<Void> {
////        // Generate a list containing the contexts this widget is relevant in.
////    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let emoji: String
//}
//
//struct MCStatusWatchWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        VStack {
//            HStack {
//                Text("Time:")
//                Text(entry.date, style: .time)
//            }
//
//            Text("Emoji:")
//            Text(entry.emoji)
//        }
//    }
//}
//
//@main
//struct MCStatusWatchWidget: Widget {
//    let kind: String = "MCStatusWatchWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            MCStatusWatchWidgetEntryView(entry: entry)
//                .containerBackground(.fill.tertiary, for: .widget)
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//    }
//}
//
//#Preview(as: .accessoryRectangular) {
//    MCStatusWatchWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}
