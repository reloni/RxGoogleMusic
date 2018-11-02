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
	private func refreshToken(force: Bool) -> Single<GMusicToken> {
        return force
            |> (token |> refreshToken)
            |> saveGMusicToken
	}
    
    private func refreshToken(token: GMusicToken) -> (Bool) -> Single<GMusicToken> {
        let request = dataRequest >>> jsonRequest
        return { force in return RxGoogleMusic.refreshToken(token, force: force, jsonRequest: request) }
    }
    
    private func saveGMusicToken(from request: Single<GMusicToken>) -> Single<GMusicToken> {
        return request
            .do(onSuccess: { [weak self] in self?.token = $0 })
    }
	
	func issueApiToken(force: Bool) -> Single<GMusicToken> {
		guard apiToken?.expiresAt ?? Date(timeIntervalSince1970: 0) < Date() || force else {
			// if api token existed and not expired, return it
			return .just(apiToken!)
		}

        return force
            |> refreshToken
            |> issueApiToken
            |> saveApiToken
	}
    
    private func issueApiToken(withRefreshRequest request: Single<GMusicToken>) -> Single<GMusicToken> {
        let issueRequest = dataRequest
            >>> jsonRequest
            |> (curry(issueMusicApiToken) |> flip)
        
        return request.flatMap(issueRequest)
    }
    
    private func saveApiToken(from request: Single<GMusicToken>) -> Single<GMusicToken> {
        return request
            .do(onSuccess: { [weak self] in self?.apiToken = $0 })
    }
}
