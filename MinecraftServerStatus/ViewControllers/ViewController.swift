//
//  ViewController.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 5/29/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import MarqueeLabel
import SwiftRater
import WidgetKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ServerEditProtocol {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    var servers: Results<SavedServer>!
    @IBOutlet weak var tableView: UITableView!
    var serverStatus:[String:ServerStatusViewModel]!
    var realm: Realm! = nil
    var initialized = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = initializeRealmDb()
        self.tableView.estimatedRowHeight = 234
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // wait 5 seconds before asking for a review
            SwiftRater.check()
        }
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        self.navigationItem.leftBarButtonItem = barButton
        
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)

        serverStatus = [:]
        reloadTableData(initializeData: true)
    }

    @IBAction func editClicked(_ sender: Any) {
        if (self.tableView.isEditing == true) {
            self.tableView.setEditing(false, animated: true)
            self.editButton.title = "Edit"
        }
        else {
            self.tableView.setEditing(true, animated: true)
            self.editButton.title = "Done"
        }
    }
    
    @objc func infoButtonTapped() {
        performSegue(withIdentifier: "ShowInfo", sender: self)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.tableView.refreshControl?.endRefreshing()
        reloadTableData(initializeData: false)
    }
    
    func reloadTheme() {
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
               self.tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
               self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)

            } else {
               self.tableView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
               self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        reloadTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTheme()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        reloadTheme()
    }
    
    func reloadTableData(initializeData: Bool) {
        servers = realm.objects(SavedServer.self).sorted(byKeyPath: "order")
        
        for server in servers {
            if (initializeData) {
                self.serverStatus[server.id] = ServerStatusViewModel()
            }
            self.serverStatus[server.id]?.loading = true
            StatusChecker(addressAndPort: server.serverUrl, serverType: server.serverType).getStatus { status in
                DispatchQueue.main.async {
                    self.initialized = true
                    
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
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if servers == nil {
            return 0
        } else {
            return servers.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 234
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
           //when we delete a server we need to go through and fix the order number for everything after it
            try! realm.write {
                for server in self.servers {
                    if server.order > self.servers[indexPath.row].order {
                        server.order = server.order - 1
                    }
                }
                realm.delete(self.servers[indexPath.row])
            }
            servers = realm.objects(SavedServer.self).sorted(byKeyPath: "order")
            // Update Table View
            tableView.deleteRows(at: [indexPath], with: .right)
            //tell widgets to refresh
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    //Sets a cell back to empty data
    func resetCellData(cell: LargeServerTableViewCell) {
        cell.statusLabel.attributedText = BoldPartOfString("Status:", label: "")
        cell.statusResultLabel.text = ""
        cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: "")
        cell.playerListLabel.text = ""
        cell.motdLabel.attributedText = BoldPartOfString("Motd: ", label: "")
        cell.versionLabel.attributedText = BoldPartOfString("Version: ", label: "")
        cell.motdMessageLabel.text = ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell", for: indexPath) as! LargeServerTableViewCell
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                cell.cardView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
                cell.loadingIndicator.color = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            } else {
                cell.cardView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
                cell.loadingIndicator.color = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            }
        } 
        
        let server = servers[indexPath.row]
        let status = self.serverStatus[server.id]!
        //set all saved data
        cell.nameLabel.text = server.name
        let addressParts = server.serverUrl.splitPort()
        
        cell.ipLabel.attributedText = BoldPartOfString("Host: ", label: addressParts.address)
        
        var serverPortVal = 0
        if let serverPort = addressParts.port {
            serverPortVal = serverPort
        } else {
            if (server.serverType == ServerType.SERVER_TYPE_JAVA) {
                serverPortVal = 25565
            } else {
                serverPortVal = 19132
            }
        }
        cell.portLabel.attributedText = BoldPartOfString("Port: ", label: String(serverPortVal))
        if server.serverIcon != "" {
            let imageString = String(server.serverIcon.split(separator: ",")[1])
            if let decodedData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
                let image = UIImage(data: decodedData)
                cell.icon.image = image
            }
        }else {
            cell.icon.image = UIImage(named: "DefaultIcon");
        }

        if status.loading {
            cell.loadingIndicator.startAnimating()
        } else {
            cell.loadingIndicator.stopAnimating()
        }
        
        //If cell is loading and we have no saved data show a mostly blank cell
        if status.loading && (status.serverStatus?.status ?? Status.Unknown) != .Online {
            resetCellData(cell: cell)
            cell.loadingIndicator.startAnimating()
        } else if let status = status.serverStatus {
            switch (status.status) {
            case .Offline:
                resetCellData(cell: cell)
                cell.statusResultLabel.text = "OFFLINE"
                cell.statusResultLabel.textColor = UIColor(rgb: 0xCC0000)
                break
            case .Unknown:
                resetCellData(cell: cell)
                cell.statusResultLabel.text = "UNKNOWN"
                cell.statusResultLabel.textColor = UIColor(rgb: 0x777777) // TODO: fix that color
                break
            case .Online:
                cell.statusResultLabel.text = "ONLINE"
                cell.statusResultLabel.textColor = UIColor(rgb: 0x009933)

                if let players = status.players {
                    cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: String(players.online) + "/" + String(players.max))
                    if let playerList = players.sample, playerList.count > 0 {
                        var playerListString = playerList.map{ $0.name }.joined(separator: ", ")
                        if players.online > playerList.count {
                            playerListString += ",...       "
                        }
                        cell.playerListLabel.text = playerListString
                        cell.playerListLabel.animationDelay = 3
                        cell.playerListLabel.speed =  MarqueeLabel.SpeedLimit.rate(20)
                        
                    } else if players.online > 0 && server.serverType == ServerType.SERVER_TYPE_JAVA {
                        // disabled for debrock servers
                        cell.playerListLabel.text = "The server owner has disabled the player list feature.                 "
                        cell.playerListLabel.animationDelay = 7
                        cell.playerListLabel.speed =  MarqueeLabel.SpeedLimit.rate(20)
                    } else {
                        cell.playerListLabel.text = ""
                    }
                }
                
                if let description = status.description {
                    cell.motdMessageLabel.text = description
                    cell.motdMessageLabel.animationDelay = 5
                    cell.motdMessageLabel.speed =  MarqueeLabel.SpeedLimit.rate(20)
                }
                
                if let version = status.version {
                    cell.versionLabel.attributedText = BoldPartOfString("Version: ", label: version.name)
                }

                break
            default:
                break
            }
            
        }

        return cell
    }
    
    func serverAdded(_ newServer:SavedServer) {
        self.serverStatus[newServer.id] = ServerStatusViewModel()
        reloadTableData(initializeData: false)
    }
    
    func serverEdited(_ editedServer:SavedServer) {
        reloadTableData(initializeData: false)
    }
    
    func BoldPartOfString(_ prefix: String, label: String) -> NSMutableAttributedString {
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
        let attributedString = NSMutableAttributedString(string: prefix, attributes:attrs)
        let normalString = NSMutableAttributedString(string:" " + label)
        attributedString.append(normalString)
        return attributedString
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "NewItem" || segue.identifier == "EditItem")  {
            let nav = segue.destination as! UINavigationController
            let dest = nav.topViewController as! NewServerViewController
            dest.delegate = self
            if (segue.identifier == "EditItem") {
                let cell = sender as! UITableViewCell
                let index = tableView.indexPath(for: cell)!
                dest.serverToEdit = servers[index.row]
            }
        } else if (segue.identifier == "ShowInfo") {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    //for when a person is reordering the tableview cells
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //borrowed from https://gist.github.com/kishikawakatsumi/cc4a1f32fb8ee34eb509d54027d731b5
        try! realm.write {
            let sourceObject = servers[sourceIndexPath.row]
            let destinationObject = servers[destinationIndexPath.row]
            
            let destinationObjectOrder = destinationObject.order
            
            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let object = servers[index]
                    object.order -= 1
                }
            } else {
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                    let object = servers[index]
                    object.order += 1
                }
            }
            sourceObject.order = destinationObjectOrder
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //bad hack to turn off edit mode after the new screen has appeared without using a delegate
    }
    
    //check that hte name is unique
    func checkForName(_ serverName:String) -> Bool {
        for server in self.servers {
            if server.name == serverName {
                return true
            }
        }
        return false
    }
}

