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
		return Observable.create { observer in
			let subscribtion = self.session.invoke(request: URLRequest.authAdviceRequest())
				.do(onNext: { data in
					guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
						fatalError("Should throw error here")
					}
					
					guard let uri = URL(string: json["uri"] as? String ?? "") else {
						fatalError("Should throw error here")
					}
					
					observer.onNext(uri)
					observer.onCompleted()
				})
				.do(onError: { observer.onError($0) })
				.subscribe()
			
			return Disposables.create([subscribtion])
		}
	}
	
	public func exchangeOAuthCodeForToken(_ code: String) -> Observable<GMusicToken> {
		return Observable.create { observer in
			let subscribtion = self.session.invoke(request: URLRequest.codeForTokenExchangeRequest(code))
				.do(onNext: { data in
					guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
						fatalError("Should throw error here")
					}
					
					guard let accessToken = json["access_token"] as? String, accessToken.count > 0 else {
						fatalError("Should throw error here")
					}
					
					let token = GMusicToken(accessToken: accessToken,
											expiresIn: json["expires_in"] as? Int,
											refreshToken: json["refresh_token"] as? String)
					
					observer.onNext(token)
					observer.onCompleted()
				})
				.do(onError: { observer.onError($0) })
				.subscribe()
			
			return Disposables.create([subscribtion])
		}
	}
	
	public func issueMusicApiToken(withToken token: GMusicToken) -> Observable<GMusicToken> {
		return Observable.create { observer in
			let subscribtion = self.session.invoke(request: URLRequest.issueMusicApiTokenRequest(token: token))
				.do(onNext: { data in
					guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
						fatalError("Should throw error here")
					}
					
					guard let accessToken = json["token"] as? String, accessToken.count > 0 else {
						fatalError("Should throw error here")
					}
					
					let token = GMusicToken(accessToken: accessToken,
											expiresIn: Int(json["expiresIn"] as? String ?? ""),
											refreshToken: nil)
					
					observer.onNext(token)
					observer.onCompleted()
				})
				.do(onError: { observer.onError($0) })
				.subscribe()
			
			return Disposables.create([subscribtion])
		}
	}
}
