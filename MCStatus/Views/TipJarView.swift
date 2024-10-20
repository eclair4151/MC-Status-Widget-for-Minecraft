//
//  TipJarView.swift
//  MCStatus
//
//  Created by Tomer Shemesh on 10/16/24.
//


import SwiftUI
import StoreKit

struct TipJarView: View {
    @State private var isProcessing: Bool = false
    @State private var tipProducts: [Product]?
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Support the app!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            Image(systemName: "party.popper.fill").resizable().scaledToFit().frame(width: 100, height: 100).padding()
            Text("This app is free, ad-less, and open-source. If you find it useful, consider tipping to help keep it going!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            if let products = tipProducts {
                ForEach(products, id: \.self) { product in
                    Button(action: {
                        Task {
                            await purchaseTip(product: product)
                        }
                    }) {
                        Text("Tip \(product.displayPrice)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom,5)
                    .disabled(isProcessing)
                }
            } else {
                ProgressView("Loading Tip Option...")
            }

            Spacer()

            Text("Thank you for your support!")
                .font(.footnote)
                .padding(.bottom)
        }
        .padding()
        .onAppear {
            Task {
                await loadTipProducts()
            }
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isPresented = false
                } label: {
                    Text("Cancel")
                }
            }
        }
        
        
    }
    private func loadTipProducts() async {
        do {
            let products = try await Product.products(for: ["com.shemeshapps.MinecraftServerStatus.199Tip", "com.shemeshapps.MinecraftServerStatus.499Tip", "com.shemeshapps.MinecraftServerStatus.999Tip"])
   
            self.tipProducts = Array(products).sorted { p1, p2 in
                return p1.price < p2.price
            }
        } catch {
            print("Failed to load tip product: \(error)")
        }
    }
    private func purchaseTip(product: Product) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await handlePurchase(transaction)
                case .unverified(_, let error):
                    alertTitle = "Purchase Error"
                    alertMessage = "Transaction verification failed: \(error.localizedDescription)"
                    showAlert = true
                }
            case .userCancelled:
                break
            default:
                break
            }
        } catch {
            alertTitle = "Purchase Failed"
            alertMessage = "There was an error processing your purchase: \(error.localizedDescription)"
            showAlert = true
        }
    }
    

    // Handle successful purchase transaction
    private func handlePurchase(_ transaction: StoreKit.Transaction) async {
        // Process the purchase (e.g., thank the user, unlock features, etc.)
        print("Purchase successful!")
        await transaction.finish() // Finish the transaction
        alertTitle = "Thank You"
        alertMessage = "Thank you for supporting the development of MC Status! Your contribution helps keep the app ad-free and open source for everyone."
        showAlert = true
    }

}
