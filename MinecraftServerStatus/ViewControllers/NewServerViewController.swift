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
    func spaceForWidgetItem() -> Bool

}

class NewServerViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var showInWidgetSwitch: UISwitch!
    @IBOutlet weak var serverUrlInput: UITextField!
    @IBOutlet weak var serverNameInput: UITextField!
    
    var delegate: ServerEditProtocol!
    var serverToEdit: SavedServer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //only if we are editing an existing server not creating as new one
        if (self.serverToEdit != nil) {
            self.serverUrlInput.text = self.serverToEdit.serverUrl
            self.serverNameInput.text = self.serverToEdit.name
            self.showInWidgetSwitch.setOn(self.serverToEdit.showInWidget, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        serverUrlInput.underline()
        serverNameInput.underline()
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
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    //when the save do some verification and maybe throw an error
    @IBAction func saveButtonClicked(_ sender: Any) {
        if (serverNameInput.text?.isEmpty)! || (serverUrlInput.text?.isEmpty)! {
            alertBox("Error", message: "Field is empty", controller: self)
        } else if (self.delegate.checkForName(serverNameInput.text!) && (serverToEdit == nil || serverToEdit.name != serverNameInput.text!)) {
            alertBox("Error", message: "You already have a server with that name", controller: self)
        } else if (self.showInWidgetSwitch.isOn && !delegate.spaceForWidgetItem()) {
            alertBox("Error", message: "You can only show 4 servers in your widget at once. Disable another before adding this one", controller: self)
        } else if (self.serverToEdit == nil) {
            //creating new server
            let realm = try! Realm()

            let servers = realm.objects(SavedServer.self)
            let server = SavedServer()
            server.name = serverNameInput.text!
            server.serverUrl = serverUrlInput.text!
            server.showInWidget = self.showInWidgetSwitch.isOn
            server.order = servers.count + 1
            try! realm.write {
                realm.add(server)
            }
            delegate.serverAdded(server)
            self.dismiss(animated: true, completion: nil)
        } else {
            //saving old server
            let realm = try! Realm()
            try! realm.write {
                serverToEdit.name = serverNameInput.text!
                serverToEdit.serverUrl = serverUrlInput.text!
                serverToEdit.showInWidget = self.showInWidgetSwitch.isOn
            }
            delegate.serverEdited(serverToEdit)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
