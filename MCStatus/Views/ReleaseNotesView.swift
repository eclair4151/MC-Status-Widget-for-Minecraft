//
//  ReleaseNotesView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/17/24.
//


import SwiftUI

// Feature model to hold title, description, icon, and icon color
struct Feature: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
}

struct ReleaseNotesView: View {
    @Environment(\.dismiss) var dismiss // Allows dismissing the sheet when done
    @Environment(\.openURL) private var openURL

    @State private var showingTipSheet = false

    // Accept an array of features
    let features = [
        Feature(title: "Total Rewrite from Scratch", description: "The app has been completely re-engineered using SwiftUI and SwiftData. It also introduces native network and parsing layers for ultra-fast operation.", icon: "arrow.triangle.2.circlepath.circle.fill", iconColor: .blue),
        Feature(title: "Support for Shortcuts", description: "Quickly check your server's status with customizable Shortcuts.", icon: "link", iconColor: .green),
        Feature(title: "Support for Siri", description: "Ask Siri for your server's status without lifting a finger!", icon: "mic.fill", iconColor: .orange),
        Feature(title: "iCloud Syncing Support", description: "Sync your server list seamlessly across all of your devices.", icon: "icloud", iconColor: .blue),
        Feature(title: "Custom Dark/Tinted Icons & Widgets", description: "Personalize your app and widgets with custom colors and styles.", icon: "paintbrush.fill", iconColor: .purple),
        Feature(title: "Apple Watch App & Complications", description: "Get MC Status on your wrist with the new Apple Watch app, along with a full suite of complications for your watch faces.", icon: "applewatch.watchface", iconColor: .gray),
        Feature(title: "New Inline Widgets", description: "New inline widgets for your lock screen and Apple Watch", icon: "rectangle.fill.on.rectangle.angled.fill", iconColor: .indigo),
        Feature(title: "Refreshable Widgets", description: "Widgets now include a manual refresh button to keep your server statuses up-to-date.", icon: "arrow.clockwise", iconColor: .pink),
        Feature(title: "Support for SRV & Server MOTD", description: "The app now supports domain SRV records, and shows correctly formatted server MOTD (message of the day).", icon: "server.rack", iconColor: .red),
        Feature(title: "More Coming Soon!", description: "Stay tuned for more exciting features in upcoming releases!", icon: "sparkles", iconColor: .yellow)
    ]

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("I'm thrilled to announce the release of **MC Status 2.0**, a total rewrite from the ground up! Get ready for a blazing fast app experience, with tons of new features and enhancements.")
                        .font(.body)
                        .padding(.bottom, 20)
                    
                    // Loop through each feature and display it dynamically
                    ForEach(features) { feature in
                        FeatureRow(feature: feature)
                    }
                    
                    // Thank You & Tip/Review Buttons Section
                    Divider()
                        .padding(.vertical, 20)

                    VStack(alignment: .center) {
                        Text("Thank you for your support!")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        Text("If you love the app, consider leaving a review or leaving a small tip to help support development!")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                        
                        HStack(spacing: 10) {
                            Button(action: {
                                leaveAppReview()
                            }) {
                                Label("Leave a Review", systemImage: "star.fill")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .font(.callout)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
                            }
                            
                            Button(action: {
                                showingTipSheet = true
                            }) {
                                Label("Leave a $1.99 Tip", systemImage: "gift.fill")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .font(.callout)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)

                            }
                        }.frame(maxWidth: .infinity)

                    }
                    
                }
                .padding([.leading, .trailing, .bottom], 30)
            }
            .navigationTitle("MC Status 2.0")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Got it!") {
                        dismiss() // Close the sheet when the user is done
                    }
                }
            }.sheet(isPresented: $showingTipSheet) {
                NavigationStack {
                    TipJarView(isPresented: $showingTipSheet)
                }
            }
    }
    
    
    func leaveAppReview() {
        // Replace the placeholder value below with the App Store ID for your app.
        // You can find the App Store ID in your app's product URL.
        let url = "https://apps.apple.com/app/id1408215245?action=write-review"
        guard let writeReviewURL = URL(string: url) else {
            print("Expected a valid URL")
            return
        }
        openURL(writeReviewURL)
    }
}

// View for individual feature row
struct FeatureRow: View {
    let feature: Feature
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: feature.icon)
                .foregroundColor(feature.iconColor)
                .imageScale(.large)
                .scaledToFit()
                .frame(width: 25,height: 25)
            VStack(alignment: .leading) {
                Text(feature.title)
                    .font(.headline)
                    .bold()
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}
