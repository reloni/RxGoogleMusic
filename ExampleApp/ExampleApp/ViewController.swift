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
	
	let working_gmusic: URL = {
		let host = "accounts.google.com"
		let path = "embedded/setup/v2/safarivc"
		let scope = "scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email"
		let clientId = "client_id=936475272427.apps.googleusercontent.com"
		let delegated_client_id = "delegated_client_id=228293309116.apps.googleusercontent.com"
		let hl = "hl=ru"
		let device_name = "device_name=iPhone"
		//let auth_extension = "auth_extension=ADa53XKad2bqcW2HiRZ08aB8YECipSG9yVGUP8AEoWGR359nJ6yOTPXbNil2D5CiT67m48gBMLUp7ing2c03fHCZ_nk9uHFqjwv5IWlQdzMBsfyBqUg5sF4"
		let auth_extension = "auth_extension=ADa53XLeimIbXEKskF0--dVQs-RK0qBMztk7u_H88f7js1d18e_8X_L_ciLugPytFEgfn9UPwrBM6lJ0wyqt3bwaTw7urH4KB_GEDNjsruR9AS_JOGfqHZo"
		let system_version = "system_version=\(UIDevice.current.systemVersion)"
		let appVersion = "app_version=1.0"
		let kdlc = "kdlc=1"
		let kdac = "kdac=1"
//		let `as` = "as=237d84991ca1076"
		let `as` = "as=-6a1802a0a7cd8c2b"
		let redirectUri = "redirect_uri=com.google.sso.228293309116:/authCallback?login%3Dcode"
		let sarp = "sarp=1"
		let wvmode = "wv_mode=0"
		let params = [scope, clientId, delegated_client_id, hl, device_name, auth_extension, system_version, appVersion, `as`, sarp, redirectUri, wvmode].joined(separator: "&")
		return URL(string: "https://\(host)/\(path)?\(params)")!
	}()
	
	var session: SFAuthenticationSession!
	
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
		
//		session = SFAuthenticationSession(url: url, callbackURLScheme: nil, completionHandler: { callbackUrl, error in
//			print("======== callbackurl: \(callbackUrl)")
//			print("======== error: \(error)")
//			guard let callbackUrl = callbackUrl else { return }
//			self.loadToken(for: callbackUrl) { token in
//				print("obrtained token: \(token)")
//			}
//		})
//
//		session.start()
	}
	
	func loadToken_old(withCode code: String, callback: @escaping (GMusicToken) -> Void) {
//		let comp = URLComponents(url: url, resolvingAgainstBaseURL: false)!
//		let code = comp.queryItems!.first(where: { $0.name == "authorization_code" })!.value!
		
		let body = "grant_type=authorization_code&code=\(code)&client_id=936475272427.apps.googleusercontent.com&client_secret=KWsJlkaMn1jGLxQpWxMnOox-&scope=https%3A%2F%2Fwww.google.com%2Faccounts%2FOAuthLogin"
		
//		body += "&redirect_uri=com.google.sso.228293309116:/oauth2redirect/google"
		
		var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v4/token")!)
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			print("token response code: \((response as? HTTPURLResponse)?.statusCode)")
			if let data = data, let responseJson = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
				print(responseJson)
			}
			
			if let error = error {
				print("error: \(error)")
			}
			}.resume()
	}
	
	func authAdvice2(callback: @escaping (URL) ->Void) {
		let body = "chrome_installed=false&client_id=228293309116.apps.googleusercontent.com&device_id=cba09321-d88f-4200-a3a7-c7d08d2a572c&device_name=iPhone&hl=ru&lib_ver=1.0&mediator_client_id=936475272427.apps.googleusercontent.com&package_name=com.google.PlayMusic&redirect_uri=com.google.sso.228293309116%3A%2FauthCallback"
		
		var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v3/authadvice")!)
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
		request.addValue("GET", forHTTPHeaderField: "x-http-method-override")
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			print("advice response")
			if let data = data, let responseJson = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
				if let url = responseJson["uri"] as? String {
					var comp = URLComponents(string: url)
//					if let index = comp?.queryItems?.index(where: { $0.name == "wv_mode" }) {
//						//						comp?.queryItems?.remove(at: index)
//						comp?.queryItems?[index] = URLQueryItem(name: "wv_mode", value: "0")
//					}
					callback(comp!.url!)
				}
			}
			
			if let error = error {
				print("error: \(error)")
			}
			}.resume()
	}

	func authAdvice(callback: @escaping (URL) ->Void) {
//		let minimumJson =
//		"""
//		{
//		"redirect_uri": "com.google.sso.228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o:/authCallback",
//		"fast_setup": "false",
//		"mediator_client_id": "936475272427.apps.googleusercontent.com",
//		"device_id": "\(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)",
//		"hl": "\(Locale.current.identifier)"
//		}
//		"""
		
		let json = 	"""
		{
		"report_user_id": "true",
		"system_version": "\(UIDevice.current.systemVersion)",
		"app_version": "1.0",
		"user_id": [],
		"request_trigger": "ADD_ACCOUNT",
		"lib_ver": "3.2",
		"package_name": "com.google.PlayMusic",
		"supported_service": ["uca"],
		"redirect_uri": "com.google.sso.228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o:/authCallback",
		"device_name": "iPhone",
		"fast_setup": "true",
		"mediator_client_id": "936475272427.apps.googleusercontent.com",
		"device_id": "\(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)",
		"hl": "ru-RU",
		"client_id": "228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o.apps.googleusercontent.com"
		}
		"""
		
		var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v3/authadvice")!)
		request.addValue("application/json", forHTTPHeaderField: "content-type")
		request.httpMethod = "POST"
		request.httpBody = json.data(using: .utf8)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			print("advice response")
			if let data = data, let responseJson = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
				if let url = responseJson["uri"] as? String {
					var comp = URLComponents(string: url)
					if let index = comp?.queryItems?.index(where: { $0.name == "wv_mode" }) {
//						comp?.queryItems?.remove(at: index)
						comp?.queryItems?[index] = URLQueryItem(name: "wv_mode", value: "0")
					}
					callback(comp!.url!)
				}
			}
			
			if let error = error {
				print("error: \(error)")
			}
		}.resume()
	}
}

extension ViewController: WKNavigationDelegate {
//	func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//		print("challenge!!")
//		print(challenge)
//	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//		navigationResponse.response.coo
		
		decisionHandler(.allow)
	}
	
	func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
		print("redirect")
		print(navigation)
	}
	
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		guard webView.url?.absoluteString == "https://accounts.google.com/embedded/close" else { return }
		print("didStartProvisionalNavigation")
		print(navigation)
		print(webView.url)
		WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
			guard let oauth_code = cookies.first(where: { $0.name == "oauth_code" })?.value else { return }
//			print("code is HERE: \(oauth_code)")
//			self.loadToken(withCode: oauth_code) { token in
//				print("obtained token: \(token)")
//			}
			self.tokenClient.exchangeOAuthCodeForToken(oauth_code)
				.do(onNext: { print("Exchanged token: \($0)") })
				.do(onError: { print("Error while exchanging token: \($0)") })
				.subscribe()
				.disposed(by: self.bag)
		}
	}
}
