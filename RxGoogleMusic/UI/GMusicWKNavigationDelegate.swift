//
//  GMusicWKNavigationDelegate.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 06.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import WebKit

open class GMusicWKNavigationDelegate: NSObject, WKNavigationDelegate {
	let oauthCodeCallback: (String) -> Void
	
	public init(oauthCodeCallback: @escaping (String) -> Void) {
		self.oauthCodeCallback = oauthCodeCallback
	}
	
	public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		guard webView.url?.absoluteString.hasSuffix("embedded/close") == true else { return }
		WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
			guard let oauthCode = cookies.first(where: { $0.name == "oauth_code" })?.value else { return }
			self.oauthCodeCallback(oauthCode)
		}
	}
}
