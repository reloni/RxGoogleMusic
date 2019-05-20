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

open class GMusicAuthenticationController: ViewController {
    public enum AuthenticationResult {
        case authenticated(GMusicToken)
        case userAborted
        case error(GMusicError)
    }
    
    let bag = DisposeBag()
    let session: URLSession
    let callback: (AuthenticationResult) -> ()
    let exchangeRequest: (String) -> Single<GMusicToken>
    
    lazy var webView: WKWebView = {
        let view = WKWebView()
        
        #if os(macOS)
        // force mobile version
        view.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B91"
        #endif
        
        return view
    }()
    
    lazy var webViewDelegate: GMusicWKNavigationDelegate = {
        return GMusicWKNavigationDelegate { [weak self] oauthCode in
            guard let self = self else { return }
            self.exchangeRequest(oauthCode)
                .observeOn(MainScheduler.instance)
                .do(onSuccess: { [weak self] in self?.complete(withToken: $0) })
                .do(onError: { [weak self] in self?.complete(withError: $0) })
                .subscribe()
                .disposed(by: self.bag)
        }
    }()
    
    
    #if os(iOS)
    let toolBar = UIToolbar()
    #endif
    
    let deviceId: UUID
    
    public init(deviceId: UUID,
                session: URLSession = URLSession.shared,
                callback: @escaping (AuthenticationResult) -> ()) {
        self.deviceId = deviceId
        self.callback = callback
        self.session = session
        self.exchangeRequest = session
            |> jsonRequest
            |> (curry(exchangeOAuthCodeForToken) |> flip)
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Authentication"
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
        
        #if os(iOS)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        #endif
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.navigationDelegate = webViewDelegate
        
        setupToolbar()
        
        setupConstraints()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAuthenticationUrl()
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
    
    func complete(withError error: Error) {
        close()
        callback(.error(GMusicAuthenticationController.createGMusicError(error)))
    }
    
    func complete(withToken token: GMusicToken) {
        close()
        callback(.authenticated(token))
    }
    
    @objc func backButttonTapped() {
        close()
        callback(.userAborted)
    }
    
    @objc func loadAuthenticationUrl() {
        gMusicAuthenticationUrl(for: session |> jsonRequest, deviceId: deviceId)
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { [weak self] url in
                self?.webView.load(loginPageRequest(url, self?.deviceId ?? UUID()))
                
            })
            .do(onError: { [weak self] in
                self?.complete(withError: $0)
                
            })
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
        toolBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        toolBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        // web view
        webView.topAnchor.constraint(equalTo: toolBar.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        #elseif os(macOS)
        // web view
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 500).isActive = true
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: 600).isActive = true
        #endif
        
        // web view
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#if os(macOS)
extension GMusicAuthenticationController: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        callback(.userAborted)
    }
}
#endif
