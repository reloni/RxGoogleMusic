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
    func refreshToken(force: Bool) -> Single<GMusicToken> {
        return RxGoogleMusic.refreshToken(token, force: force, jsonRequest: dataRequest >>> jsonRequest)
            |> Single.doOnSuccess { [weak self] in self?.token = $0 }
    }
	
	func issueApiToken(force: Bool) -> Single<GMusicToken> {
		guard apiToken?.expiresAt ?? Date(timeIntervalSince1970: 0) < Date() || force else {
			// if api token existed and not expired, return it
			return .just(apiToken!)
		}
        
        let issueToken = dataRequest
            >>> jsonRequest
            |> (curry(issueMusicApiToken) |> flip)
            |> Single.flatMap
        
        return force
            |> refreshToken
            >>> issueToken
            >>> Single.doOnSuccess { [weak self] in self?.apiToken = $0 }
	}
}
