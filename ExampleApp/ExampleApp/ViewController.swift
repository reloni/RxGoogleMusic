//
//  ViewController.swift
//  ExampleApp
//
//  Created by Anton Efimenko on 03.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import SafariServices

/*
URL	https://accounts.google.com/embedded/setup/ios?
scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email&
client_id=936475272427.apps.googleusercontent.com&
as=6683ceab3677c48&
delegated_client_id=228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o.apps.googleusercontent.com&
hl=ru-RU&
device_name=iPhone&
auth_extension=ADa53XJPouLB2nG3r6wIBJEAIwKQjkX28FC73szeYdCbJaQl6xCjB6WmSNdhi4sNT9O0ta1XnI_YW0tH3OeFuFm2nFy8U5aD_bMmmbGEZz50sYCK8nu3aYM&
system_version=11.2.1&
app_version=3.38.1007&
kdlc=1&
kdac=1
*/

/*
https://accounts.google.com/embedded/setup/v2/safarivc?
as=237d84991ca1076&
scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email&
client_id=936475272427.apps.googleusercontent.com&
redirect_uri=com.google.sso.228293309116:/authCallback?login%3Dcode&sarp=1&
delegated_client_id=228293309116.apps.googleusercontent.com&
hl=ru&
device_name=iPhone&
auth_extension=ADa53XKad2bqcW2HiRZ08aB8YECipSG9yVGUP8AEoWGR359nJ6yOTPXbNil2D5CiT67m48gBMLUp7ing2c03fHCZ_nk9uHFqjwv5IWlQdzMBsfyBqUg5sF4&
lib_ver=1.0&
wv_mode=1
*/
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
		print("working: \(working_gmusic)")
		print("not working: https://accounts.google.com/embedded/setup/v2/safarivc?as=347a15ec856b0c75&scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email&client_id=936475272427.apps.googleusercontent.com&redirect_uri=com.google.sso.228293309116:/authCallback?login%3Dcode&sarp=1&delegated_client_id=228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o.apps.googleusercontent.com&hl=ru-RU&device_name=iPhone&auth_extension=ADa53XKs5xbxIN7iKIwUHr0joOGUWDVJhmQ1eDCNchjRFAD4SDjEsGQnM270tD5gzdKeX4dcU2NFw0Q2SO9gZ-_hSaEwXp-0_zzh2-uO8heBgC7JAoxwCbk&system_version=11.2&app_version=1.0&kdlc=1&kdac=1&lib_ver=3.2&wv_mode=1")
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
		
		session = SFAuthenticationSession(url: url, callbackURLScheme: nil, completionHandler: { callbackUrl, error in
			print("======== callbackurl: \(callbackUrl)")
			print("======== error: \(error)")
		})

		session.start()
		
//		let controller = SFSafariViewController(url: url)
//		controller.delegate = self
//		present(controller, animated: true, completion: nil)
	}
	
//	func authAdvice2(callback: @escaping (URL) ->Void) {
//		let body = "chrome_installed=false&client_id=228293309116.apps.googleusercontent.com&device_id=cba09321-d88f-4200-a3a7-c7d08d2a572c&device_name=iPhone&hl=ru&lib_ver=1.0&mediator_client_id=936475272427.apps.googleusercontent.com&package_name=com.google.PlayMusic&redirect_uri=com.google.sso.228293309116%3A%2FauthCallback"
//
//		var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v3/authadvice")!)
//		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
//		request.addValue("GET", forHTTPHeaderField: "x-http-method-override")
//		request.httpMethod = "POST"
//		request.httpBody = body.data(using: .utf8)
//
//		URLSession.shared.dataTask(with: request) { data, response, error in
//			print("advice response")
//			if let data = data, let responseJson = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
//				if let url = responseJson["uri"] as? String {
//					callback(URL(string: url)!)
//				}
//			}
//
//			if let error = error {
//				print("error: \(error)")
//			}
//			}.resume()
//	}
	
	func authAdvice(callback: @escaping (URL) ->Void) {
		
//		let json = 	"""
//					{
//					"report_user_id": "true",
//					"system_version": "\(UIDevice.current.systemVersion)",
//					"app_version": "1.0",
//					"user_id": [],
//					"request_trigger": "ADD_ACCOUNT",
//					"lib_ver": "3.2",
//					"package_name": "com.google.PlayMusic",
//					"supported_service": ["uca"],
//					"redirect_uri": "com.google.sso.myApp:/authCallback",
//					"device_name": "iPhone",
//					"fast_setup": "false",
//					"mediator_client_id": "936475272427.apps.googleusercontent.com",
//					"device_id": "\(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)",
//					"hl": "ru-RU",
//					"client_id": "228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o.apps.googleusercontent.com"
//					}
//					"""
		let minimumJson =
		"""
		{
		"redirect_uri": "com.google.sso.myApp:/authCallback",
		"fast_setup": "false",
		"mediator_client_id": "936475272427.apps.googleusercontent.com",
		"device_id": "\(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)",
		"hl": "\(Locale.current.identifier)"
		}
		"""
		
//		print("request json: \(json)")
		
		var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v3/authadvice")!)
		request.addValue("application/json", forHTTPHeaderField: "content-type")
		request.httpMethod = "POST"
		request.httpBody = minimumJson.data(using: .utf8)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			print("advice response")
			if let data = data, let responseJson = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
				if let url = responseJson["uri"] as? String {
					callback(URL(string: url.replacingOccurrences(of: "&wv_mode=1", with: ""))!)
				}
			}
			
			if let error = error {
				print("error: \(error)")
			}
		}.resume()
	}
}

extension ViewController: SFSafariViewControllerDelegate {
	func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
		
		print(URL)
	}
	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		print("finish")
	}
}

// 	"uri": "https://accounts.google.com/embedded/setup/ios?scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email&client_id=936475272427.apps.googleusercontent.com&as=-6ea57af4d2538bfc&delegated_client_id=228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o.apps.googleusercontent.com&hl=ru-RU&device_name=iPhone&auth_extension=ADa53XJ-QRSWufeEK1V6aKxE7rgSJGdGSV24CuDPhynXdFHaJGW1hcXTM7Lk9spAC3j__MAyfuczRvKej-jmYpX-wYKc_pXy_divDZq1NsWKgMDqlW9k0kg&system_version=11.2.1&app_version=3.38.1007&kdlc=1&kdac=1",
