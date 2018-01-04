//
//  ViewController.swift
//  ExampleApp
//
//  Created by Anton Efimenko on 03.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import SafariServices

struct Token: Decodable {
	let access_token: String
	let expires_in: Int
	let id_token: String
	let refresh_token: String
	let token_type: String
}

class ViewController: UIViewController {
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

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
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
		
		session = SFAuthenticationSession(url: working_gmusic, callbackURLScheme: nil, completionHandler: { callbackUrl, error in
			print("======== callbackurl: \(callbackUrl)")
			print("======== error: \(error)")
			guard let callbackUrl = callbackUrl else { return }
			self.loadToken(for: callbackUrl) { token in
				print("obrtained token: \(token)")
			}
		})

		session.start()
	}
	
	func loadToken(for url: URL, callback: @escaping (Token) -> Void) {
		let comp = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		let code = comp.queryItems!.first(where: { $0.name == "authorization_code" })!.value!
		
		var body = "grant_type=authorization_code&code=\(code)&client_id=936475272427.apps.googleusercontent.com&client_secret=KWsJlkaMn1jGLxQpWxMnOox-&scope=https%3A%2F%2Fwww.google.com%2Faccounts%2FOAuthLogin"
		
//		body += "&redirect_uri=com.google.sso.228293309116:/authCallback"
		
		var request = URLRequest(url: URL(string: "https://accounts.google.com/o/oauth2/token")!)
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
		"redirect_uri": "com.google.sso.228293309116:/authCallback",
		"device_name": "iPhone",
		"fast_setup": "false",
		"mediator_client_id": "936475272427.apps.googleusercontent.com",
		"device_id": "\(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)",
		"hl": "ru-RU",
		"client_id": "228293309116.apps.googleusercontent.com"
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
