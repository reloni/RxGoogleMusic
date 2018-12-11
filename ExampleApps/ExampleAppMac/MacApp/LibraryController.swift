//
//  LibraryController.swift
//  MacApp
//
//  Created by Anton Efimenko on 11/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa

class LibraryController: NSViewController {
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = title ?? ""
    }
}
