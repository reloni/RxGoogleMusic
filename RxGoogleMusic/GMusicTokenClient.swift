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
	let session: URLSession
	
	public init(session: URLSession = URLSession.shared) {
		self.session = session
	}
	
	init(session: URLSession = URLSession.shared,
				tokenUrl: URL = GMusicConstants.tokenUrl,
				issueTokenUrl: URL = GMusicConstants.issueTokenUrl) {
		self.session = session
	}
	
	public func loadAuthenticationUrl() -> Observable<URL> {
		return session.jsonRequest(URLRequest.authAdviceRequest())
			.flatMap { json -> Observable<URL> in
				guard let uri = URL(string: json["uri"] as? String ?? "") else {
					fatalError("Should throw error here")
				}
				return .just(uri)
		}
	}
	
	public func exchangeOAuthCodeForToken(_ code: String) -> Observable<GMusicToken> {
		return session.jsonRequest(URLRequest.codeForTokenExchangeRequest(code))
			.flatMap { json -> Observable<GMusicToken> in
				guard let token = GMusicToken(json: json) else {
					// TODO: Should throw error here
					fatalError("Unable to create token object")
				}
				return .just(token)
		}
	}
	
//	public func refreshToken(_ token: GMusicToken, force: Bool) -> Observable<GMusicToken> {
//		guard let refreshToken = token.refreshToken, (token.isTokenExpired || force) else {
//			// TODO: Maybe should return error if there is no refresh token
//			return .just(token)
//		}
//		
//		return .empty()
////		guard let refreshToken =
//	}
	
	public func issueMusicApiToken(withToken token: GMusicToken) -> Observable<GMusicToken> {
		return session.jsonRequest(URLRequest.issueMusicApiTokenRequest(token: token))
			.flatMap { json -> Observable<GMusicToken> in
				guard let token = GMusicToken(apiTokenJson: json) else {
					// TODO: Should throw error here
					fatalError("Unable to create token object")
				}
				return .just(token)
		}
	}
}
