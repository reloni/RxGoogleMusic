//
//  GMusicClient+Token.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 07.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

extension GMusicClient {
	func refreshToken(force: Bool) -> Observable<GMusicToken> {
		return tokenClient.refreshToken(token, force: force)
			.do(onNext: { [weak self] in self?.token = $0 })
	}
	
	func issueApiToken(force: Bool) -> Observable<GMusicToken> {
		guard apiToken?.expiresAt ?? Date(timeIntervalSince1970: 0) < Date() || force else {
			// if api token existed and not expired, return it
			return .just(apiToken!)
		}
		
		return tokenClient.refreshToken(token, force: force)
			.flatMap { [weak self] token in return self?.tokenClient.issueMusicApiToken(withToken: token) ?? .empty() }
			.do(onNext: { [weak self] in self?.apiToken = $0 })
	}
}
