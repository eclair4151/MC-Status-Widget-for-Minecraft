import SwiftUI
import StoreKit

struct TipJarView: View {
    @Binding var isPresented: Bool
    
    init(_ isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    @State private var isProcessing = false
    @State private var tipProducts: [Product]?
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 15) {
                Text("Support the app!")
                    .largeTitle(.bold)
                    .padding(.top)
                
                Image(systemName: "party.popper.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
                
                Text("This app is free, ad-less, and open-source. If you find it useful, consider tipping to help keep it going!")
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let products = tipProducts {
                    ForEach(products) { product in
                        Button {
                            Task {
                                await purchaseTip(product: product)
                            }
                        } label: {
                            Text("Tip \(product.displayPrice)")
                                .headline()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom,3)
                        .disabled(isProcessing)
                    }
                } else {
                    ProgressView("Loading Tip Option...")
                }
                
                Text("Thank you for your support!")
                    .footnote()
                    .padding(.vertical)
            }
            .padding(.horizontal)
        }
        .onAppear {
            Task {
                await loadTipProducts()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    isPresented = false
                }
            }
        }
    }
    
    private func loadTipProducts() async {
        do {
            let products = try await Product.products(for: [
                "dev.topscrech.MinecraftServerStatus.199Tip",
                "dev.topscrech.MinecraftServerStatus.499Tip",
                "dev.topscrech.MinecraftServerStatus.999Tip"
            ])
            
            tipProducts = Array(products).sorted { p1, p2 in
                return p1.price < p2.price
            }
        } catch {
            print("Failed to load tip product: \(error)")
        }
    }
    
    private func purchaseTip(product: Product) async {
        isProcessing = true
        
        defer {
            isProcessing = false
        }
        
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
        
        // Finish transaction
        await transaction.finish()
        
        alertTitle = "Thank You"
        alertMessage = "Thank you for supporting the development of MC Status! Your contribution helps keep the app ad-free and open source for everyone."
        showAlert = true
    }
}
