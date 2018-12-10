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

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func buttonTapped(_ sender: Any) {
        _ = Observable.from(["Rx"]).subscribe(onNext: { self.showAlert(withMessage: $0) })
    }
    
    func showAlert(withMessage message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

