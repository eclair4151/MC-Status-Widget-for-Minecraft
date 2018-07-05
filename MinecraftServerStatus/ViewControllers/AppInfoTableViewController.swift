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
    }
    
    @IBAction func appReviewClicked(_ sender: Any) {
        SwiftRater.rateApp()
    }
    

}
