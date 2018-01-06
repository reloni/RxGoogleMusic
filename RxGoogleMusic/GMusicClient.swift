//
//  GMusicClient.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

final public class GMusicClient {
	public let baseUrl: URL
	public let session: URLSession
	public let locale: Locale
	public let tier: String
	public let token: GMusicToken
	public internal (set) var  apiToken: GMusicToken? = nil
	lazy var tokenClient: GMusicTokenClient = { GMusicTokenClient(session: self.session) }()
	
	public convenience init(token: GMusicToken, session: URLSession = URLSession.shared, locale: Locale = Locale.current) {
		self.init(token: token, session: session, locale: locale, tier: "aa", baseUrl: GMusicConstants.apiBaseUrl)
	}
	
	init(token: GMusicToken, session: URLSession, locale: Locale, tier: String, baseUrl: URL) {
		self.token = token
		self.session = session
		self.locale = locale
		self.tier = tier
		self.baseUrl = baseUrl
	}
}
