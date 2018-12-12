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
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = title ?? ""
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
        
        controller.client = GMusicClient(token: token,
                                         session: URLSession(configuration: URLSessionConfiguration.default),
                                         locale: Locale.current)
        
        present(controller, animator: ReplaceWindowControllerAnimator())
    }
}
