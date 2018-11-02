//
//  GMusicAuthenticationController.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 06.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import WebKit
import RxSwift

open class GMusicAuthenticationController: UIViewController {
	public enum AuthenticationResult {
		case authenticated(GMusicToken)
		case userAborted
		case error(GMusicError)
	}
	
	let bag = DisposeBag()
	let webView = WKWebView()
	let toolBar = UIToolbar()
    let session: URLSession
	let callback: (AuthenticationResult) -> ()
    let exchangeRequest: (String) -> Single<GMusicToken>
    
	lazy var webViewDelegate: GMusicWKNavigationDelegate = {
		return GMusicWKNavigationDelegate { [weak self] oauthCode in
			guard let object = self else { return }
			object.exchangeRequest(oauthCode)
				.observeOn(MainScheduler.instance)
				.do(onSuccess: { [weak self] token in self?.complete(with: token) })
				.do(onError: { [weak self] in self?.callback(.error(GMusicAuthenticationController.createGMusicError($0))) })
				.subscribe()
				.disposed(by: object.bag)
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
		
		toolBar.translatesAutoresizingMaskIntoConstraints = false
		webView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	open override func loadView() {
		super.loadView()
		view.backgroundColor = .white
		view.addSubview(toolBar)
		view.addSubview(webView)
		
		toolBar.items = [UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButttonTapped)),
						 UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
						 UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadAuthenticationUrl))]
		
		webView.navigationDelegate = webViewDelegate
	
		setupConstraints()
	}
	
	func complete(with token: GMusicToken) {
		dismiss(animated: true, completion: nil)
		callback(.authenticated(token))
	}
	
	@objc func backButttonTapped() {
		dismiss(animated: true, completion: nil)
		callback(.userAborted)
	}
	
	@objc func loadAuthenticationUrl() {
		gMusicAuthenticationUrl(for: session |> jsonRequest)
			.observeOn(MainScheduler.instance)
			.do(onSuccess: { [weak self] url in self?.webView.load(URLRequest.loginPageRequest(url)) })
			.do(onError: { [weak self] in self?.callback(.error(GMusicAuthenticationController.createGMusicError($0))) })
			.subscribe()
			.disposed(by: bag)
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		loadAuthenticationUrl()
	}
	
	static func createGMusicError(_ value: Error) -> GMusicError {
		if let gmusicError = value as? GMusicError { return gmusicError  }
		return GMusicError.unknown(value)
	}
	
	func setupConstraints() {
		// setup toolBar bar
		view.addConstraint(NSLayoutConstraint(item: toolBar, attribute: .top, relatedBy: .equal,
											  toItem: view, attribute: .topMargin, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: toolBar, attribute: .leading, relatedBy: .equal,
											  toItem: view, attribute: .leading, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: toolBar, attribute: .trailing, relatedBy: .equal,
											  toItem: view, attribute: .trailing,multiplier: 1, constant: 0))
		
		// setup web view
		view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal,
											  toItem: toolBar, attribute: .bottom, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal,
											  toItem: view, attribute: .leading, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal,
											  toItem: view, attribute: .trailing,multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal,
											  toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0))
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
