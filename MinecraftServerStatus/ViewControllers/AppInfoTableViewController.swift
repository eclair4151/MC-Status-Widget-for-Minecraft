//
//  AppInfoTableViewController.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 7/1/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import UIKit
import SwiftRater

class AppInfoTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func viewSourceClicked(_ sender: Any) {
        UIApplication.shared.open(URL(string : "https://github.com/eclair4151/MinecraftServerStatusWidget")!, options: [:], completionHandler: { (status) in
            
        })
    }
    
    @IBAction func appReviewClicked(_ sender: Any) {
        SwiftRater.rateApp()
    }
    

}
