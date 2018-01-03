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
	let url: URL = {
		let host = "accounts.google.com"
		let path = "embedded/setup/v2/safarivc"
		let scope = "scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email"
		let clientId = "client_id=936475272427.apps.googleusercontent.com"
		let delegated_client_id = "delegated_client_id=228293309116.apps.googleusercontent.com"
		let hl = "hl=\(Locale.current.identifier)"
		let device_name = "device_name=iPhone"
		let auth_extension = "auth_extension=ADa53XKad2bqcW2HiRZ08aB8YECipSG9yVGUP8AEoWGR359nJ6yOTPXbNil2D5CiT67m48gBMLUp7ing2c03fHCZ_nk9uHFqjwv5IWlQdzMBsfyBqUg5sF4"
		let system_version = "system_version=\(UIDevice.current.systemVersion)"
		let appVersion = "app_version=1.0"
		let kdlc = "kdlc=1"
		let kdac = "kdac=1"
		let `as` = "as=237d84991ca1076"
		let redirectUri = "redirect_uri=com.google.sso.228293309116:/authCallback?login%3Dcode"
		let params = [scope, clientId, delegated_client_id, hl, device_name, auth_extension, system_version, appVersion, `as`, redirectUri].joined(separator: "&")
		return URL(string: "https://\(host)/\(path)?\(params)")!
	}()
	
	var session: SFAuthenticationSession!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		print(String("228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o".reversed()))
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		
	}

	@IBAction func authenticate(_ sender: Any) {
		// https://accounts.google.com/embedded/setup/v2/safarivc?as=6337ec33bd418784&scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email&client_id=936475272427.apps.googleusercontent.com&redirect_uri=com.google.sso.228293309116:/authCallback?login%3Dcode&sarp=1&delegated_client_id=228293309116.apps.googleusercontent.com&hl=ru&device_name=iPhone&auth_extension=ADa53XLlskm0lJdBfI2Eczzj7afLYzBB_iMjJ8MJGpvdDjio4zUdhfulKPWEacgpiLQPKp9sZXVlcKwevll3dSQ6pjk0ZxowTPytQW6JVFdWAMSMHQ5h51Q&lib_ver=1.0&wv_mode=1
		
		
		let url2 = URL(string: "https://accounts.google.com/embedded/setup/v2/safarivc?as=6337ec33bd418784&scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email&client_id=936475272427.apps.googleusercontent.com&redirect_uri=com.google.sso.228293309116:/authCallback?login%3Dcode&sarp=1&delegated_client_id=228293309116.apps.googleusercontent.com&hl=ru&device_name=iPhone&auth_extension=ADa53XLlskm0lJdBfI2Eczzj7afLYzBB_iMjJ8MJGpvdDjio4zUdhfulKPWEacgpiLQPKp9sZXVlcKwevll3dSQ6pjk0ZxowTPytQW6JVFdWAMSMHQ5h51Q&lib_ver=1.0&wv_mode=1")!
//		let url2 = URL(string: "https://accounts.google.com/embedded/setup/ios?scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email&client_id=936475272427.apps.googleusercontent.com&as=1f192cd4a1da333f&delegated_client_id=228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o.apps.googleusercontent.com&hl=ru-RU&device_name=iPhone&auth_extension=ADa53XKobZj63dyWcBaPcrZq7JHa8SrOIVOd7h-dWaqKSmEz-VRIaUNjbK4mGQrntOXRzUDe_u1s9hpchAdkjxKYWtQPYQXWrbdSOb4MHzekEdgovjM3xLc&system_version=11.2.1&app_version=3.38.1007&kdlc=1&kdac=1")!
		
//		https://accounts.google.com/o/oauth2/v2/auth?response_type=code&code_challenge_method=S256&scope=openid%20profile&code_challenge=KfSdRCNa0pJTrEfhOAe8zKuLjt2y68b03hI4Khn4irI&redirect_uri=com.googleusercontent.apps.48866222172-2an2vqj4khhur1v9igjn3knd9et6lrkf:/oauth2redirect/google&client_id=48866222172-2an2vqj4khhur1v9igjn3knd9et6lrkf.apps.googleusercontent.com&state=vFe_XuJtIj5ofWIBcWUwgiXf34XhMKygbhTq_jzW1yI
		
		let working_Own_App = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&code_challenge_method=S256&scope=openid%20profile&code_challenge=KfSdRCNa0pJTrEfhOAe8zKuLjt2y68b03hI4Khn4irI&redirect_uri=com.googleusercontent.apps.48866222172-2an2vqj4khhur1v9igjn3knd9et6lrkf:/oauth2redirect/google&client_id=48866222172-2an2vqj4khhur1v9igjn3knd9et6lrkf.apps.googleusercontent.com&state=vFe_XuJtIj5ofWIBcWUwgiXf34XhMKygbhTq_jzW1yI")!
		// com.googleusercontent.apps.48866222172-2an2vqj4khhur1v9igjn3knd9et6lrkf:/oauth2redirect/
//		~!@#
//		let url3 = URL(string: "https://accounts.google.com/embedded/setup/v2/safarivc?as=6337ec33bd418784&scope=https://www.google.com/accounts/OAuthLogin+https://www.googleapis.com/auth/userinfo.email&client_id=936475272427.apps.googleusercontent.com&redirect_uri=com.googleusercontent.apps.48866222172-2an2vqj4khhur1v9igjn3knd9et6lrkf:/oauth2redirect/&sarp=1&delegated_client_id=228293309116.apps.googleusercontent.com&hl=ru&device_name=iPhone&auth_extension=ADa53XLlskm0lJdBfI2Eczzj7afLYzBB_iMjJ8MJGpvdDjio4zUdhfulKPWEacgpiLQPKp9sZXVlcKwevll3dSQ6pjk0ZxowTPytQW6JVFdWAMSMHQ5h51Q&lib_ver=1.0&wv_mode=1")!
		
//		UIApplication.shared.open(url2!, options: [:], completionHandler: nil)
//		print("open url: \(url)")
//		let svc = SFSafariViewController(url: url3)
//		svc.delegate = self
//		present(svc, animated: true, completion: nil)
		
		session = SFAuthenticationSession(url: url, callbackURLScheme: nil, completionHandler: { callbackUrl, error in
			print("======== callbackurl: \(callbackUrl)")
			print("======== error: \(error)")
		})
		
		session.start()
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
