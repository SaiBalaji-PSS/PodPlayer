//
//  BaseViewController.swift
//  PodPlayer
//
//  Created by Sai Balaji on 28/01/24.
//

import Cocoa

class BaseViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func showAlert(title: String,message: String){
        let alert = NSAlert.init()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
}
