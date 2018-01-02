//
//  GMusicClient.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

final class GMusicClient {
	public let baseUrl: URL
	public let session: URLSession
	public let locale: Locale
	let tier: String
	
	public init(session: URLSession = URLSession.shared,
				locale: Locale = Locale.current,
				tier: String = "aa",
				baseUrl: URL = URL(string: "https://mclients.googleapis.com/sj/v2.5")!) {
		self.session = session
		self.locale = locale
		self.tier = tier
		self.baseUrl = baseUrl
	}
}
