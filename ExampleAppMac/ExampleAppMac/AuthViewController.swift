//
//  AuthViewController.swift
//  ExampleAppMac
//
//  Created by Anton Efimenko on 10/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxSwift
import Foundation
import RxGoogleMusic
import WebKit

class AuthViewController: NSViewController {
    let webView = WKWebView()
    
    override func loadView() {
        view = NSView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLoad() {
        view.addSubview(webView)
        
        setupConstraints()
        
        let req = URLRequest(url: URL(string: "https://google.com")!)
        webView.load(req)
    }
    
    func setupConstraints() {
        // setup web view
        
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal,
                                              toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal,
                                              toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal,
                                              toItem: view, attribute: .trailing,multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal,
                                              toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .greaterThanOrEqual,
                                              toItem: nil, attribute: .height, multiplier: 1, constant: 500))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .greaterThanOrEqual,
                                              toItem: nil, attribute: .width, multiplier: 1, constant: 500))
    }
    
    
}

extension AuthViewController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        print("close")
    }
}
