//
//  AppInfoTableViewController.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 7/1/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import UIKit
import SwiftRater
import StoreKit

class AppInfoTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
   
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard let trans = transactions.first else {
            return
        }
        
        if trans.transactionState == .failed {
            let alert = UIAlertController(title: "Error", message: "The in app purchase failed. Please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            SKPaymentQueue.default().finishTransaction(trans)
            return
        } else if trans.transactionState == .purchased {
            SKPaymentQueue.default().finishTransaction(trans)
            showThanksPopup()
        }
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
       print("product count \(response.products.count)")
       print("invalid product IDs \(response.invalidProductIdentifiers)")
       self.products = response.products
    }

    let SwiftShopping = "com.shemeshapps.MinecraftServerStatus.199Donation"
    var products:[SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let idents:Set = [SwiftShopping]
        SKPaymentQueue.default().add(self)
        let productRequest = SKProductsRequest(productIdentifiers: idents)
        productRequest.delegate = self
        productRequest.start()
    }

    
    func showThanksPopup() {
        let alert = UIAlertController(title: "Thanks!", message: "I really hope you found this app useful, and appreciate people like you who allow me to do this.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "You're Welcome!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDonationPayent() {
        if self.products.count > 0 {
            let payment = SKPayment(product: self.products[0])
            SKPaymentQueue.default().add(payment)
        } else {
            let alert = UIAlertController(title: "Error", message: "We were unable to load the purchase from the store. Please check your connection and try again.", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                   self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            UIApplication.shared.open(URL(string : "https://github.com/eclair4151/MinecraftServerStatusWidget")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (status) in
                
            })
        } else if indexPath.section == 1 {
            SwiftRater.rateApp()
        } else if indexPath.section == 2 {
          showDonationPayent()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
