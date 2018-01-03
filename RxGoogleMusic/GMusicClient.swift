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
	
	convenience init(session: URLSession = URLSession.shared, locale: Locale = Locale.current) {
		self.init(session: session, locale: locale, tier: "aa", baseUrl: URL(string: "https://mclients.googleapis.com/sj/v2.5")!)
	}
	
	init(session: URLSession,
				locale: Locale,
				tier: String,
				baseUrl: URL) {
		self.session = session
		self.locale = locale
		self.tier = tier
		self.baseUrl = baseUrl
	}
}
