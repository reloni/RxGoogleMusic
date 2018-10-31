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
	public internal (set) var token: GMusicToken
	public internal (set) var  apiToken: GMusicToken? = nil
	lazy var tokenClient: GMusicTokenClient = { GMusicTokenClient(session: self.session) }()
    let dataRequest: (URLRequest) -> Single<Data>
	
	public convenience init(token: GMusicToken, session: URLSession = URLSession.shared, locale: Locale = Locale.current) {
		self.init(token: token, session: session, locale: locale, baseUrl: GMusicConstants.apiBaseUrl)
	}
	
	init(token: GMusicToken, session: URLSession, locale: Locale, baseUrl: URL) {
		self.token = token
		self.session = session
		self.locale = locale
		self.baseUrl = baseUrl
        self.dataRequest = sessionDataRequest(session)
	}
}
