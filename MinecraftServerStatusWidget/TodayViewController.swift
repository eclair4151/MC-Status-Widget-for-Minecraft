//
//  TodayViewController.swift
//  MinecraftServerStatusWidget
//
//  Created by Tomer on 5/29/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftyJSON
import MarqueeLabel
import RealmSwift
import Realm

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var noServersView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var expanded: Bool!
    
    var servers: Results<SavedServer>!
    var serverStatus:[String:ServerStatusViewModel]!
    var realm:Realm!
    var numServersToShow:Int = 0
    var rowHeight:CGFloat = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = self.rowHeight
        
        //for shaing realm data between app and widget
        let sharedDirectory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.shemeshapps.MinecraftServerStatus")! as URL
        let sharedRealmURL = sharedDirectory.appendingPathComponent("db.realm")
        Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: sharedRealmURL)
        
        self.realm = try! Realm()
        let predicate = NSPredicate(format: "showInWidget == %@", NSNumber(value: true))
        servers = realm.objects(SavedServer.self).sorted(byKeyPath: "order").filter(predicate)

        //set to compact mode if only 1 server
        if (servers.count <= 1) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.compact
        } else {
            self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        }
        
        if servers.count == 0 {
            self.noServersView.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noServersView.isHidden = true
            self.tableView.isHidden = false
        }
        serverStatus = [:]
        self.numServersToShow = servers.count
        for server in servers {
            serverStatus[server.id] = ServerStatusViewModel()
            getServer(server: server.serverUrl) { response in
                
                let serverStatus = self.serverStatus[server.id]
                serverStatus?.loading = false
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    serverStatus?.serverData = json
                    
                    if let imageString = json["icon"].string {
                        try! self.realm.write {
                            server.serverIcon = imageString
                        }
                    }
                case .failure(let error):
                    print(error)
                    serverStatus?.error = true
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //returns the number of servers we should show in the widget
    func maxNumServers(maxSize: Int) -> Int {
        return min(maxSize/Int(self.rowHeight), servers.count)
    }


    //keep track of what mode we are in.
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        self.rowHeight = self.extensionContext!.widgetMaximumSize(for: .compact).height
        
        if activeDisplayMode == .expanded {
            expanded = true
            self.preferredContentSize = CGSize(width: maxSize.width, height: self.rowHeight * CGFloat(maxNumServers(maxSize: Int(maxSize.height))))
        } else if activeDisplayMode == .compact {
            expanded = false
            self.preferredContentSize = CGSize(width: maxSize.width, height: self.rowHeight)
        }
    }
    
    
    func BoldPartOfString(_ prefix: String, label: String) -> NSMutableAttributedString {
        let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)]
        let attributedString = NSMutableAttributedString(string: prefix, attributes:attrs)
        let normalString = NSMutableAttributedString(string:" " + label)
        attributedString.append(normalString)
        return attributedString
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerRow", for: indexPath) as! ServerTableViewCell
        let server = servers[indexPath.row]
        let status = self.serverStatus[server.id]!
        
        if server.serverIcon != "" {
            let imageString = String(server.serverIcon.split(separator: ",")[1])
            if let decodedData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
                let image = UIImage(data: decodedData)
                cell.icon.image = image
            }
        } else {
            cell.icon.image = UIImage(named: "DefaultIcon");
        }
        
        cell.nameLabel.text = server.name
        
        if status.loading {
            cell.statusLabel.text = ""
            cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: "")
            cell.playerListLabel.text = ""
            cell.activityIndicator.startAnimating()
        } else {
            cell.activityIndicator.stopAnimating()
            if status.error {
                cell.statusLabel.text = "UNKNOWN"
                cell.statusLabel.textColor = UIColor(rgb: 0x000000)
                cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: "")
                cell.playerListLabel.text = ""
            } else {
                if status.serverData["offline"].boolValue {
                    cell.statusLabel.text = "OFFLINE"
                    cell.statusLabel.textColor = UIColor(rgb: 0xCC0000)
                    cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: "")
                    cell.playerListLabel.text = ""
                } else {
                    cell.statusLabel.text = "ONLINE"
                    cell.statusLabel.textColor = UIColor(rgb: 0x009933)
                    
                    cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: String(status.serverData["players"]["online"].intValue) + "/" + String(status.serverData["players"]["max"].intValue))
    
                    if let playerArray = status.serverData["players"]["list"].array {
                        var playerString = Array(playerArray.prefix(20)).map { String($0.stringValue) }.joined(separator: ", ")
                        if playerArray.count > 20 {
                            playerString += ",...       "
                        }
                        cell.playerListLabel.text = playerString
                        cell.playerListLabel.animationDelay = 3
                        cell.playerListLabel.speed =  MarqueeLabel.SpeedLimit.rate(20)
                    } else {
                        cell.playerListLabel.text = ""
                    }
                }
            }
        }
        
        cell.nameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.playerCountLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.playerListLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numServersToShow
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openAppPressed(self)
    }
    
    
    @IBAction func openAppPressed(_ sender: Any) {
        let myAppUrl = URL(string: "open-app:")!
        extensionContext?.open(myAppUrl, completionHandler: { (success) in
        })
    }
}
