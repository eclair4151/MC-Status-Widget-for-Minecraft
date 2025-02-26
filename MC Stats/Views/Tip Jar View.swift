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
                                await purchaseTip(product)
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
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .toolbar {
#warning("Check on macOS")
#if os(macOS)
            let placement: ToolbarItemPlacement = .primaryAction
#else
            let placement: ToolbarItemPlacement = .topBarLeading
#endif
            
            ToolbarItem(placement: placement) {
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
    
    private func purchaseTip(_ product: Product) async {
#if os(macOS)
        guard let scene = NSApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            alertTitle = "Purchase Error"
            alertMessage = "Could not find an active window for the transaction"
            showAlert = true
            return
        }
#else
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) else {
            alertTitle = "Purchase Error"
            alertMessage = "Could not find an active scene for the transaction"
            showAlert = true
            return
        }
#endif
        isProcessing = true
        
        defer {
            isProcessing = false
        }
        
        do {
#warning("macOS")
#if !os(macOS)
            let result = try await product.purchase(confirmIn: scene, options: [])
            
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
                
            default:
                break
            }
#endif
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
        alertMessage = "Thank you for supporting the development of MC Stats! Your contribution helps keep the app ad-free and open source for everyone!"
        showAlert = true
    }
}
