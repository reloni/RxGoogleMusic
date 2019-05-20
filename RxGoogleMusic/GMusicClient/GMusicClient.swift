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
	public let locale: Locale
    public let deviceId: UUID
	public internal (set) var token: GMusicToken
	public internal (set) var  apiToken: GMusicToken? = nil
    let dataRequest: (URLRequest) -> Single<Data>
	
    public convenience init(token: GMusicToken, deviceId: UUID, session: URLSession = URLSession.shared, locale: Locale = Locale.current) {
		self.init(token: token, deviceId: deviceId, session: session, locale: locale, baseUrl: GMusicConstants.apiBaseUrl)
	}
	
	init(token: GMusicToken, deviceId: UUID, session: URLSession, locale: Locale, baseUrl: URL) {
		self.token = token
        self.deviceId = deviceId
		self.locale = locale
		self.baseUrl = baseUrl
        self.dataRequest = session |> RxGoogleMusic.dataRequest
	}
}
