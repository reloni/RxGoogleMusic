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
            .do(onSuccess: { [weak self] in self?.token = $0 })
	}
	
	func issueApiToken(force: Bool) -> Single<GMusicToken> {
		guard apiToken?.expiresAt ?? Date(timeIntervalSince1970: 0) < Date() || force else {
			// if api token existed and not expired, return it
			return .just(apiToken!)
		}
        let saveToken = self |> (saveApiToken |> curry |> flip)
        return force
            |> refreshToken
            |> issueApiToken
            |> saveToken
	}
    
    func issueApiToken(withRefreshRequest request: Single<GMusicToken>) -> Single<GMusicToken> {
        let issueRequest = dataRequest
            >>> jsonRequest
            |> (curry(issueMusicApiToken) |> flip)
        
        return request.flatMap(issueRequest)
    }
    
    func saveApiToken(from request: Single<GMusicToken>, in client: GMusicClient) -> Single<GMusicToken> {
        return request
            .do(onSuccess: { client.apiToken = $0 })
    }
}
