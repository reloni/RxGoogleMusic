//
//  GMusicTokenClient.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 05.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

public struct GMusicTokenClient {
    let jsonRequest: (URLRequest) -> Single<JSON>
	
	public init(session: URLSession = URLSession.shared) {
        self.jsonRequest = sessionJsonRequest(session)
	}
	
	init(session: URLSession = URLSession.shared,
				tokenUrl: URL = GMusicConstants.tokenUrl,
				issueTokenUrl: URL = GMusicConstants.issueTokenUrl) {
        self.jsonRequest = sessionJsonRequest(session)
	}
	
	static func tokenJsonToObject(_ json: JSON) -> Single<GMusicToken> {
		guard let token = GMusicToken(json: json) else {
			return .error(GMusicError.unableToRetrieveAccessToken(json: json))
		}
		return .just(token)
	}
	
	public func loadAuthenticationUrl() -> Single<URL> {
		return jsonRequest(URLRequest.authAdviceRequest())
			.flatMap { json -> Single<URL> in
				guard let uri = URL(string: json["uri"] as? String ?? "") else {
					return .error(GMusicError.unableToRetrieveAuthenticationUri(json: json))
				}
				return .just(uri)
		}
	}
	
	public func exchangeOAuthCodeForToken(_ code: String) -> Single<GMusicToken> {
		return jsonRequest(URLRequest.codeForTokenExchangeRequest(code))
			.flatMap(GMusicTokenClient.tokenJsonToObject)
	}
	
	public func refreshToken(_ token: GMusicToken, force: Bool) -> Single<GMusicToken> {
		guard let refreshToken = token.refreshToken, (token.isTokenExpired || force) else {
			// TODO: Maybe should return error if there is no refresh token
			return .just(token)
		}
		
		return jsonRequest(URLRequest.tokenRefreshRequest(forRefreshToken: refreshToken))
			.flatMap(GMusicTokenClient.tokenJsonToObject)
	}
	
	public func issueMusicApiToken(withToken token: GMusicToken) -> Single<GMusicToken> {
		return jsonRequest(URLRequest.issueMusicApiTokenRequest(token: token))
			.flatMap { json -> Single<GMusicToken> in
				guard let token = GMusicToken(apiTokenJson: json) else {
					return .error(GMusicError.unableToRetrieveAccessToken(json: json))
				}
				#if DEBUG
					print("Issued API token: \(token.accessToken)")
				#endif
				return .just(token)
		}
	}
}
