//
//  GMusicAuthenticationController.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 10/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

#if os(iOS)
import UIKit
public typealias ViewController = UIViewController
#elseif os(macOS)
import Cocoa
public typealias ViewController = NSViewController
#endif

import WebKit
import RxSwift

open class GMusicAuthenticationController_universal: ViewController {
    public enum AuthenticationResult {
        case authenticated(GMusicToken)
        case userAborted
        case error(GMusicError)
    }
    
    let bag = DisposeBag()
    let webView = WKWebView()
    #if os(iOS)
    let toolBar = UIToolbar()
    #endif
    let session: URLSession
    let callback: (AuthenticationResult) -> ()
    let exchangeRequest: (String) -> Single<GMusicToken>
    
    lazy var webViewDelegate: GMusicWKNavigationDelegate = {
        return GMusicWKNavigationDelegate { [weak self] oauthCode in
            guard let self = self else { return }
            self.exchangeRequest(oauthCode)
                .observeOn(MainScheduler.instance)
                .do(onSuccess: { [weak self] token in self?.complete(with: token) })
                .do(onError: { [weak self] in self?.callback(.error(GMusicAuthenticationController_universal.createGMusicError($0))) })
                .subscribe()
                .disposed(by: self.bag)
        }
    }()
    
    public init(session: URLSession = URLSession.shared,
                callback: @escaping (AuthenticationResult) -> ()) {
        self.callback = callback
        self.session = session
        self.exchangeRequest = session
            |> jsonRequest
            |> (curry(exchangeOAuthCodeForToken) |> flip)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        #if os(iOS)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        #endif
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        loadAuthenticationUrl()
    }
    
    open override func loadView() {
        #if os(iOS)
        super.loadView()
        view.backgroundColor = .white
        #elseif os(macOS)
        view = NSView()
        view.window?.delegate = self
        #endif
        
        view.addSubview(webView)
        
        setupToolbar()
        
        webView.navigationDelegate = webViewDelegate
        
        setupConstraints()
    }
    
    func setupToolbar() {
        #if os(iOS)
        view.addSubview(toolBar)
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButttonTapped)),
                         UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadAuthenticationUrl))]
        #endif
    }
    
    func close() {
        #if os(iOS)
        dismiss(animated: true, completion: nil)
        #elseif os(macOS)
        dismiss(self)
        #endif
    }
    
    func complete(with token: GMusicToken) {
        close()
        callback(.authenticated(token))
    }
    
    @objc func backButttonTapped() {
        close()
        callback(.userAborted)
    }
    
    @objc func loadAuthenticationUrl() {
        gMusicAuthenticationUrl(for: session |> jsonRequest)
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { [weak self] url in self?.webView.load(loginPageRequest(url)) })
            .do(onError: { [weak self] in self?.callback(.error(GMusicAuthenticationController_universal.createGMusicError($0))) })
            .subscribe()
            .disposed(by: bag)
    }
    
    static func createGMusicError(_ value: Error) -> GMusicError {
        if let gmusicError = value as? GMusicError { return gmusicError  }
        return GMusicError.unknown(value)
    }
    
    func setupConstraints() {
        #if os(iOS)
        // toolBar bar
        view.addConstraint(NSLayoutConstraint(item: toolBar, attribute: .top, relatedBy: .equal,
                                              toItem: view, attribute: .topMargin, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: toolBar, attribute: .leading, relatedBy: .equal,
                                              toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: toolBar, attribute: .trailing, relatedBy: .equal,
                                              toItem: view, attribute: .trailing,multiplier: 1, constant: 0))
        
        // web view
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal,
                                              toItem: toolBar, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal,
                                              toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0))
        #elseif os(macOS)
        // web view
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal,
                                              toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal,
                                              toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .greaterThanOrEqual,
                                              toItem: nil, attribute: .height, multiplier: 1, constant: 500))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .greaterThanOrEqual,
                                              toItem: nil, attribute: .width, multiplier: 1, constant: 500))
        #endif
        
        // web view
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal,
                                              toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal,
                                              toItem: view, attribute: .trailing,multiplier: 1, constant: 0))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#if os(macOS)
extension GMusicAuthenticationController_universal: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        callback(.userAborted)
    }
}
#endif
