//
//  ViewController.swift
//  ExampleAppMac
//
//  Created by Anton Efimenko on 09/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxSwift
import Foundation
import RxGoogleMusic
import WebKit

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func buttonTapped(_ sender: Any) {
        let authController = GMusicAuthenticationController { result in
            print("result: \(result)")
        }
//        presentAsSheet(authController)
        presentAsModalWindow(authController)
    }
//    
//    func showAlert(withMessage message: String) {
//        let alert = NSAlert()
//        alert.messageText = message
//        alert.alertStyle = .informational
//        alert.addButton(withTitle: "OK")
//        alert.runModal()
//    }
}

