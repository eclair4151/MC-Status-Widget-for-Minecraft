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
            refreshServer(server: server)
        }
    }
    
    
    func refreshServer(server: SavedServer) {
        serverStatus[server.id] = ServerStatusViewModel()
        StatusChecker(addressAndPort: server.serverUrl).getStatus { status in
            DispatchQueue.main.async {
                let serverStatusVm = self.serverStatus[server.id]
                serverStatusVm?.loading = false
                serverStatusVm?.serverStatus = status
            
                if let imageString = status.favicon {
                    try! self.realm.write {
                        server.serverIcon = imageString
                    }
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
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
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

        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                cell.activityIndicator.color = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            } else {
                cell.activityIndicator.color = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                
            }
        }
        
        cell.icon.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        
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
        cell.refreshButton.tag = indexPath.row
        
        if status.loading {
            cell.activityIndicator.startAnimating()
            cell.refreshButton.isHidden = true
            cell.statusLabel.text = ""
            cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: "")
            cell.playerListLabel.text = ""
        } else {
            cell.activityIndicator.stopAnimating()
            cell.refreshButton.isHidden = false
            cell.refreshButton.addTarget(self, action:#selector(self.refreshPressed), for: .touchUpInside)
            switch (status.serverStatus?.status) {
            case .Offline:
                cell.statusLabel.text = "OFFLINE"
                cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: "")
                cell.playerListLabel.text = ""
                cell.statusLabel.textColor = UIColor(rgb: 0xCC0000)
                break
            case .Unknown:
                cell.statusLabel.text = "UNKNOWN"
                cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: "")
                cell.playerListLabel.text = ""
                cell.statusLabel.textColor = UIColor(rgb: 0x777777)
                break
            case .Online:
                cell.statusLabel.text = "ONLINE"
                cell.statusLabel.textColor = UIColor(rgb: 0x008a2e)

                if let players = status.serverStatus?.players {
                    cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: String(players.online) + "/" + String(players.max))
                    if let playerList = players.sample {
                        var playerListString = playerList.map{ $0.name }.joined(separator: ", ")
                        if players.online > playerList.count {
                            playerListString += ",...       "
                        }
                        cell.playerListLabel.text = playerListString
                        cell.playerListLabel.animationDelay = 3
                        cell.playerListLabel.speed =  MarqueeLabel.SpeedLimit.rate(20)
                        
                    } else if players.online > 0 {
                        cell.playerListLabel.text = "The server owner has disabled the player list feature.                 "
                        cell.playerListLabel.animationDelay = 7
                        cell.playerListLabel.speed =  MarqueeLabel.SpeedLimit.rate(20)
                    } else {
                        cell.playerListLabel.text = ""
                    }
                }
                
                break
            default:
                break
            }
        }
       

        

        cell.nameLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        cell.playerCountLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        cell.playerListLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)

        return cell
    }
    
    @objc func refreshPressed(sender: UIButton!) {
       let serverToUpdate = self.servers[sender.tag]
        refreshServer(server: serverToUpdate)
       self.tableView.reloadData()
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
