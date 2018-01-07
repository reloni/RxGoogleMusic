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

public class GMusicAuthenticationController: UIViewController {
	public enum AuthenticationResult {
		case authenticated(GMusicToken)
		case userAborted
	}
	
	let bag = DisposeBag()
	let webView = WKWebView()
	let toolBar = UIToolbar()
	let tokenClient: GMusicTokenClient
	let callback: (AuthenticationResult) -> ()
	lazy var webViewDelegate: GMusicWKNavigationDelegate = {
		return GMusicWKNavigationDelegate { [weak self] oauthCode in
			guard let object = self else { return }
			object.tokenClient.exchangeOAuthCodeForToken(oauthCode)
				.observeOn(MainScheduler.instance)
				.do(onNext: { [weak self] token in self?.complete(with: token) })
				.do(onError: { [weak self] in self?.showErrorAlert($0) })
				.subscribe()
				.disposed(by: object.bag)
		}
	}()
	
	public init(tokenClient: GMusicTokenClient = GMusicTokenClient(),
				callback: @escaping (AuthenticationResult) -> ()) {
		self.tokenClient = tokenClient
		self.callback = callback
		
		super.init(nibName: nil, bundle: nil)
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		toolBar.translatesAutoresizingMaskIntoConstraints = false
		webView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	public override func loadView() {
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
		tokenClient.loadAuthenticationUrl()
			.observeOn(MainScheduler.instance)
			.do(onNext: { [weak self] url in self?.webView.load(URLRequest.loginPageRequest(url)) })
			.do(onError: { [weak self] in self?.showErrorAlert($0) })
			.subscribe()
			.disposed(by: bag)
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		loadAuthenticationUrl()
	}
	
	func showErrorAlert(_ error: Error) {
		fatalError("Should handle error here")
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
