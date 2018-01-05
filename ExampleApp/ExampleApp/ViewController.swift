//
//  ViewController.swift
//  ExampleApp
//
//  Created by Anton Efimenko on 03.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import SafariServices
import WebKit
import RxGoogleMusic
import RxSwift

class ViewController: UIViewController {
	let bag = DisposeBag()
	let tokenClient = GMusicTokenClient()
	
	@IBOutlet weak var webView: WKWebView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		webView.navigationDelegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func authenticate(_ sender: Any) {
		authAdvice { url in
			print("advice url: \(url)")
			DispatchQueue.main.async {
				self.startAuthentiationSession(with: url)
			}
		}
	}
	
	func startAuthentiationSession(with url: URL) {
		let url = URL(string: "https://accounts.google.com/embedded/setup/ios?scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email&client_id=936475272427.apps.googleusercontent.com&as=-516ae9d58c461c5f&delegated_client_id=228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o.apps.googleusercontent.com&hl=ru-RU&device_name=iPhone&auth_extension=ADa53XK2t9MDL7JXhLLiEgdShl2rTjssNxENDwJ5b4-V9g1flUYIt_w0pmGAZue5FPknDnDGpufBR_8BMLBtUvWO_VYzOdqVV5Yka6jZk4EYwQ2JYDiWlQY&system_version=11.2.1&app_version=3.38.1007&kdlc=1&kdac=1")!
		var request = URLRequest(url: url)
		request.addValue("0604339A-AA08-48BF-8B3B-2F08FB6CA581", forHTTPHeaderField: "X-IOS-Device-ID")
		request.addValue("embedded", forHTTPHeaderField: "X-Browser-View")
		webView.load(request)
	}
	
	func authAdvice(callback: @escaping (URL) ->Void) {
		tokenClient.loadAuthenticationUrl()
			.do(onNext: { callback($0) })
			.do(onError: { print("auth advice error: \($0)") })
			.subscribe()
			.disposed(by: bag)
	}
}

extension ViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		guard webView.url?.absoluteString == "https://accounts.google.com/embedded/close" else { return }
		WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
			guard let oauth_code = cookies.first(where: { $0.name == "oauth_code" })?.value else { return }
			self.tokenClient.exchangeOAuthCodeForToken(oauth_code)
				.do(onNext: { print("Exchanged token: \($0)") })
				.do(onError: { print("Error while exchanging token: \($0)") })
				.subscribe()
				.disposed(by: self.bag)
		}
	}
}
