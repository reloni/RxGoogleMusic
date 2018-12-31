//
//  GMusicTokenHelpers.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01/11/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

// MARK: Helpers

private func tokenJsonToObject2(_ json: JSON) throws -> GMusicToken {
    guard let token = GMusicToken(json: json) else {
        throw GMusicError.unableToRetrieveAccessToken(json: json)
    }
    return token
}

private func tokenJsonToObject(_ json: JSON) -> Single<GMusicToken> {
    guard let token = GMusicToken(json: json) else {
        return .error(GMusicError.unableToRetrieveAccessToken(json: json))
    }
    return .just(token)
}

// MARK: Authentication URL
func gMusicAuthenticationUrl(for jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<URL> {
    return authAdviceRequest
        |> jsonRequest
        >>> gMusicAuthenticationUrl
}

private func gMusicAuthenticationUrl(from request: Single<JSON>) -> Single<URL> {
    return request.flatMap { json -> Single<URL> in
        guard let uri = URL(string: json["uri"] as? String ?? "") else {
            return .error(GMusicError.unableToRetrieveAuthenticationUri(json: json))
        }
        return .just(uri)
    }
}

// MARK: Token exchange
func exchangeOAuthCodeForToken(code: String, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    return code
        |> tokenExchangeRequest
        >>> jsonRequest
        >>> Single.flatMap(tokenJsonToObject)
}

// MARK: Refresh token
private func refreshToken(_ token: String, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
//    let test = token
//        |> tokenRefreshRequest
//        >>> jsonRequest

//    let t = test |> singleMap { try tokenJsonToObject2($0) }
    
    return token
        |> tokenRefreshRequest
        >>> jsonRequest
        >>> sequenceMap(tokenJsonToObject2)
//        >>> Single.flatMap(tokenJsonToObject)
        >>> sequenceMap { $0.withNew(refreshToken: token) }
//        >>> (token |> (attachExistedRefreshToken |> curry))
    
//    return token
//        |> tokenRefreshRequest
//        >>> jsonRequest
//        >>> Single.flatMap(tokenJsonToObject)
//        >>> (token |> (attachExistedRefreshToken |> curry))
}

func refreshToken(_ token: GMusicToken, force: Bool, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    guard let current = token.refreshToken, (token.isTokenExpired || force) else {
        #warning("Maybe should return error if there is no refresh token")
        return .just(token)
    }

    return refreshToken(current, jsonRequest: jsonRequest)
}

//private func attachExistedRefreshToken(_ token: String?, to request: Single<GMusicToken>) -> Single<GMusicToken> {
//    return request.map { $0 |> (\.refreshToken .~ token) }
//}

//private func attachExistedRefreshToken2(_ token: String?) -> (GMusicToken) -> GMusicToken {
//    return { t in t |> (\.refreshToken .~ token) }
//}

// MARK: Issue token
func issueMusicApiToken(withToken token: GMusicToken, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    let r = issueMusicApiTokeRequest(token)
    let a = jsonRequest(r)
    let c = a.map(issueMusicApiToken2)
    return c
    return token
        |> issueMusicApiTokeRequest
        >>> jsonRequest
        >>> issueMusicApiToken
}

private func issueMusicApiToken2(from request: JSON) -> GMusicToken {
    fatalError()
}

private func issueMusicApiToken(from request: Single<JSON>) -> Single<GMusicToken> {
    return request.flatMap { json -> Single<GMusicToken> in
        guard let token = GMusicToken(apiTokenJson: json) else {
            return .error(GMusicError.unableToRetrieveAccessToken(json: json))
        }
        #if DEBUG
        print("Issued API token: \(token.accessToken)")
        #endif
        return .just(token)
    }
}

// MARK: Refresh and Issue
func refreshAndIssueTokens(gMusicToken token: GMusicToken, force: Bool,
                           jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<(gMusicToken: GMusicToken, apiToken: GMusicToken)> {
    let refreshToken = RxGoogleMusic.refreshToken(token, force: force, jsonRequest: jsonRequest)
    
    let issueToken = jsonRequest
        |> (curry(issueMusicApiToken) |> flip)

    return refreshToken.flatMap { gMusicToken in
            issueToken(gMusicToken).flatMap { apiToken in return .just((gMusicToken, apiToken)) }
    }
}
