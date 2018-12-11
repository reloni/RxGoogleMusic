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
        let authController = GMusicAuthenticationController { [weak self] result in
            switch result {
            case .authenticated(let token): self?.showLibrary(accessToken: token)
            case .error(let e):
                print("error: \(e)")
            case .userAborted:
                print("userAborted")
            }
        }

        presentAsModalWindow(authController)
    }
    
    func showLibrary(accessToken token: GMusicToken) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "LibraryController") as! LibraryController
        
        present(controller, animator: ReplaceWindowControllerAnimator())
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
