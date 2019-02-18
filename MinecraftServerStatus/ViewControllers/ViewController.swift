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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ServerEditProtocol {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    var servers: Results<SavedServer>!
    @IBOutlet weak var tableView: UITableView!
    var serverStatus:[String:ServerStatusViewModel]!
    var realm:Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 257

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // wait 10 seconds before asking for a review
            SwiftRater.check()
        }
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        self.navigationItem.rightBarButtonItem = barButton
        
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)

        self.realm = try! Realm()
        serverStatus = [:]
        reloadTableData(initializeData: true)
    }

    @IBAction func editClicked(_ sender: Any) {
        if(self.tableView.isEditing == true)
        {
            self.tableView.setEditing(false, animated: true)
            self.editButton.title = "Edit"
            
            let infoButton = UIButton(type: .infoLight)
            infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: infoButton)
            self.navigationItem.rightBarButtonItem = barButton
        }
        else
        {
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            self.navigationItem.rightBarButtonItem = add
            
            self.tableView.setEditing(true, animated: true)
            self.editButton.title = "Done"
        }
    }
    
    @objc func infoButtonTapped() {
        performSegue(withIdentifier: "ShowInfo", sender: self)
    }
    
    @objc func addTapped() {
        performSegue(withIdentifier: "NewItem", sender: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.editClicked(self)
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.tableView.refreshControl?.endRefreshing()
        reloadTableData(initializeData: false)
    }
    
    func reloadTableData(initializeData: Bool) {
        servers = realm.objects(SavedServer.self).sorted(byKeyPath: "order")
        
        for server in servers {
            if (initializeData) {
                self.serverStatus[server.id] = ServerStatusViewModel()
            }
            self.serverStatus[server.id]?.loading = true
            self.serverStatus[server.id]?.error = false
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
        return 257
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

        }
    }
    
    //Sets a cell back to empty data
    func resetCellData(cell: LargeServerTableViewCell) {
        cell.statusLabel.attributedText = BoldPartOfString("Status:", label: "")
        cell.statusResultLabel.text = ""
        cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: "")
        cell.playerListLabel.text = ""
        cell.portLabel.attributedText = BoldPartOfString("Port: ", label: "")
        cell.motdLabel.attributedText = BoldPartOfString("Motd: ", label: "")
        cell.versionLabel.attributedText = BoldPartOfString("Version: ", label: "")
        cell.motdMessageLabel.text = ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell", for: indexPath) as! LargeServerTableViewCell
        let server = servers[indexPath.row]
        let status = self.serverStatus[server.id]!
        //set all saved data
        cell.nameLabel.text = server.name
        cell.ipLabel.attributedText = BoldPartOfString("Host: ", label: server.serverUrl)
        cell.showInWidgetLabel.attributedText = BoldPartOfString("Show in Widget: ", label: (server.showInWidget ? "Yes" : "No"))
        
        if server.serverIcon != "" {
            let imageString = String(server.serverIcon.split(separator: ",")[1])
            if let decodedData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
                let image = UIImage(data: decodedData)
                cell.icon.image = image
            }
        }else {
            cell.icon.image = UIImage(named: "DefaultIcon");
        }
        
        //If cell is loading and we have no saved data show a mostly blank cell
        if status.loading && status.serverData == JSON.null{
            resetCellData(cell: cell)
            cell.loadingIndicator.startAnimating()
        } else {
            //other wise we want to show the data we have saved or just recevied
            
            //Show or hide the loading symbol based on if a request is mid flight
            if status.loading {
                cell.loadingIndicator.startAnimating()
            } else {
                cell.loadingIndicator.stopAnimating()
            }
            if status.error {
                //if we get an error response like no internet show unknown text
                resetCellData(cell: cell)
                cell.statusResultLabel.text = "UNKNOWN"
                cell.statusResultLabel.textColor = UIColor(rgb: 0x000000)
            } else {
                //other wise show the online of offline value
                if status.serverData["offline"].boolValue {
                    resetCellData(cell: cell)
                    cell.statusResultLabel.text = "OFFLINE"
                    cell.statusResultLabel.textColor = UIColor(rgb: 0xCC0000)
                } else {
                    cell.statusResultLabel.text = "ONLINE"
                    cell.statusResultLabel.textColor = UIColor(rgb: 0x009933)
                    cell.motdLabel.attributedText = BoldPartOfString("Motd: ", label: "")
                    cell.statusLabel.attributedText = BoldPartOfString("Status:", label: "")

                    cell.playerCountLabel.attributedText = BoldPartOfString("Players:", label: String(status.serverData["players"]["online"].intValue) + "/" + String(status.serverData["players"]["max"].intValue))
                    
                    //we cant trust the query response here. Query may return false even if it is on if udp is blocked on the server.
                    if (status.serverData["players"]["online"].intValue > 0) {
                        if let playerArray = status.serverData["players"]["list"].array {
                            var playerString = Array(playerArray.prefix(20)).map { String($0.stringValue) }.joined(separator: ", ")
                            if playerArray.count > 20 {
                                playerString += ",...       "
                            }
                            cell.playerListLabel.text = playerString
                            cell.playerListLabel.animationDelay = 3
                            cell.playerListLabel.speed =  MarqueeLabel.SpeedLimit.rate(20)
                        } else {
                            cell.playerListLabel.text = "Turn on enable-query in server.properties to see the list of players.                 "
                            cell.playerListLabel.animationDelay = 7
                            cell.playerListLabel.speed =  MarqueeLabel.SpeedLimit.rate(20)
                        }
                    } else {
                        cell.playerListLabel.text = ""
                    }
                    
                    let motdText = status.serverData["motd"]["clean"].arrayValue.map { $0.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)}.joined(separator: "   ") + "         "
                    
                    cell.motdMessageLabel.text = motdText
                    cell.motdMessageLabel.animationDelay = 5
                    cell.motdMessageLabel.speed =  MarqueeLabel.SpeedLimit.rate(20)
                    
                    cell.versionLabel.attributedText = BoldPartOfString("Version: ", label: status.serverData["version"].stringValue)
                    cell.portLabel.attributedText = BoldPartOfString("Port: ", label: status.serverData["port"].stringValue)
                }
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

