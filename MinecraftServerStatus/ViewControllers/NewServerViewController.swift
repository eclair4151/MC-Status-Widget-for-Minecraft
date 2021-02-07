//
//  NewServerViewController.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 6/2/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import UIKit
import RealmSwift

protocol ServerEditProtocol: class {
    func serverAdded(_ newServer:SavedServer)
    func serverEdited(_ editedServer:SavedServer)
    func checkForName(_ serverName:String) -> Bool
}

class NewServerViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var serverUrlInput: UITextField!
    @IBOutlet weak var serverNameInput: UITextField!
    @IBOutlet weak var portInput: UITextField!
    
    var delegate: ServerEditProtocol!
    var serverToEdit: SavedServer!
    var realm: Realm! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.realm = initializeRealmDb()

        //only if we are editing an existing server not creating as new one
        if (self.serverToEdit != nil) {
            let urlPieces =  self.serverToEdit.serverUrl.splitPort()
            self.serverUrlInput.text = urlPieces.address
            if let port = urlPieces.port {
                self.portInput.text = String(port)
            }
            self.serverNameInput.text = self.serverToEdit.name
        }
    }
    
    override func viewDidLayoutSubviews() {
        serverUrlInput.underline()
        serverNameInput.underline()
        portInput.underline()

        if #available(iOS 12.0, *) {
            reloadTheme()
        }
    }
    
    //handle users pressing next and done on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.serverNameInput {
            self.serverUrlInput.becomeFirstResponder()
        } else {
            self.serverUrlInput.endEditing(true)
        }
        return true
    }
    
    func alertBox(_ title: String, message: String, controller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    //when the save do some verification and maybe throw an error
    @IBAction func saveButtonClicked(_ sender: Any) {
        if (serverNameInput.text?.isEmpty)! || (serverUrlInput.text?.isEmpty)! {
            alertBox("Error", message: "One or more fields are empty", controller: self)
        } else if (serverUrlInput.text!.count > 200) {
            alertBox("Error", message: "Urls must be less than 200 characters", controller: self)
        } else if (self.delegate.checkForName(serverNameInput.text!) && (serverToEdit == nil || serverToEdit.name != serverNameInput.text!)) {
            alertBox("Error", message: "You already have a server with that name", controller: self)
        } else if (self.serverToEdit == nil) {
            //creating new server
            let servers = realm.objects(SavedServer.self)
            let server = SavedServer()
            server.name = serverNameInput.text!
            server.serverUrl = serverUrlInput.text!
            if (!(portInput.text?.isEmpty ?? true)) {
                server.serverUrl += ":" + portInput.text!
            }
            server.order = servers.count + 1
            try! realm.write {
                realm.add(server)
            }
            delegate.serverAdded(server)
            self.dismiss(animated: true, completion: nil)
        } else {
            //saving old server
            try! realm.write {
                serverToEdit.name = serverNameInput.text!
                serverToEdit.serverUrl = serverUrlInput.text!
                if (!(portInput.text?.isEmpty ?? true)) {
                    serverToEdit.serverUrl += ":" + portInput.text!
                }
            }
            delegate.serverEdited(serverToEdit)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
       func reloadTheme() {
           if self.traitCollection.userInterfaceStyle == .dark {
               //self.tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
               self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)

           } else {
               //self.tableView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
               self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
           }
           //self.tableView.reloadData()
       }
       
      
       
       override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
           if #available(iOS 12.0, *) {
               reloadTheme()
           }
       }
}
