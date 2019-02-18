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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            UIApplication.shared.open(URL(string : "https://github.com/eclair4151/MinecraftServerStatusWidget")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (status) in
                
            })
        } else if indexPath.section == 1{
            SwiftRater.rateApp()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
