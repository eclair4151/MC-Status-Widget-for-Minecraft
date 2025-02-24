import SwiftUI
import StoreKit

struct ReleaseNotesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    @State private var showingTipSheet = false
    var showDismissButton = true
    
    private let features = [
        Feature("Total Rewrite from Scratch", description: "The app has been completely re-engineered using SwiftUI and SwiftData. It also introduces native network and parsing layers for ultra-fast operation", icon: "arrow.triangle.2.circlepath.circle.fill", iconColor: .blue),
        Feature("Apple Watch App & Complications", description: "Get MC Stats on your wrist with the new Apple Watch app, along with a full suite of complications for your watch faces", icon: "applewatch.watchface", iconColor: .teal),
        Feature("Shortcuts", description: "Quickly check your server's status with customizable Shortcuts", icon: "link", iconColor: .green),
        Feature("Siri", description: "Ask Siri for your server's status without lifting a finger!", icon: "mic.fill", iconColor: .orange),
        Feature("iCloud Sync", description: "Sync your server list seamlessly across all of your devices", icon: "arrow.trianglehead.2.clockwise.rotate.90.icloud", iconColor: .blue),
        Feature("Custom Dark/Tinted Icons & Widgets", description: "Personalize your app and widgets with custom colors and styles", icon: "paintbrush.fill", iconColor: .purple),
        Feature("Lock Screen Widgets", description: "New inline widgets for your lock screen and Apple Watch", icon: "rectangle.fill.on.rectangle.angled.fill", iconColor: .indigo),
        Feature("Refreshable Widgets", description: "Widgets now include a manual refresh button to keep your server statuses up-to-date", icon: "arrow.clockwise", iconColor: .pink),
        Feature("Support for SRV & Server MOTD", description: "The app now supports domain SRV records, and shows correctly formatted server MOTD (message of the day)", icon: "server.rack", iconColor: .red),
        Feature("More Coming Soon!", description: "Stay tuned for more exciting features in upcoming releases!", icon: "sparkles", iconColor: .yellow)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(features) { feature in
#if os(tvOS)
                    Button {
                        
                    } label: {
                        FeatureRow(feature)
                    }
#else
                    FeatureRow(feature)
#endif
                }
                
                Divider()
                    .padding(.vertical, 5)
                
                VStack(alignment: .center) {
                    Text("Thank you for your support!")
                        .headline()
                        .padding(.bottom, 10)
                    
                    Text("If you love the app, consider leaving a review or leaving a small tip to help support development!")
                        .subheadline()
                        .multilineTextAlignment(.center)
                        .secondary()
                        .padding(.bottom, 20)
                    
                    HStack(spacing: 10) {
                        Button {
                            leaveAppReview()
                        } label: {
                            Label("Leave a Review", systemImage: "star.fill")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .callout()
                                .padding()
                                .background(.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
#warning("In-App Purchases")
                        //                        Button {
                        //                            showingTipSheet = true
                        //                        } label: {
                        //                            Label("Leave a Tip", systemImage: "gift.fill")
                        //                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        //                                .callout()
                        //                                .padding()
                        //                                .background(.blue)
                        //                                .foregroundColor(.white)
                        //                                .cornerRadius(10)
                        //                        }
                    }
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding([.leading, .trailing, .bottom], 30)
        }
        .navigationTitle("Features")
        .scrollIndicators(.never)
        .sheet($showingTipSheet) {
            NavigationStack {
                TipJarView($showingTipSheet)
            }
        }
        .toolbar {
            if showDismissButton {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Got it!") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func leaveAppReview() {
#if os(tvOS)
        let url = "https://apps.apple.com/app/6740754881?action=write-review"
        
        guard let writeReviewURL = URL(string: url) else {
            print("Expected a valid URL")
            return
        }
        
        openURL(writeReviewURL)
#else
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        SKStoreReviewController.requestReview(in: windowScene)
#endif
    }
}
