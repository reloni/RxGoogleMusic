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

private func jsonToToken(_ json: JSON) throws -> GMusicToken {
    guard let token = GMusicToken(json: json) else {
        throw GMusicError.unableToRetrieveAccessToken(json: json)
    }
    return token
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
        >>> (jsonToToken |> sequenceMap)
}

// MARK: Refresh token
private func refreshToken(_ token: String, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    return token
        |> tokenRefreshRequest
        >>> jsonRequest
        >>> (jsonToToken |> sequenceMap)
        >>> sequenceMap { $0.withNew(refreshToken: token) }}

func refreshToken(_ token: GMusicToken, force: Bool, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    guard let current = token.refreshToken, (token.isTokenExpired || force) else {
        #warning("Maybe should return error if there is no refresh token")
        return .just(token)
    }

    return refreshToken(current, jsonRequest: jsonRequest)
}

// MARK: Issue token
func issueMusicApiToken(withToken token: GMusicToken, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    return token
        |> issueMusicApiTokeRequest
        >>> jsonRequest
        >>> (issueMusicApiToken |> sequenceMap)
}

private func issueMusicApiToken(from json: JSON) throws -> GMusicToken {
    guard let token = GMusicToken(apiTokenJson: json) else {
        throw GMusicError.unableToRetrieveAccessToken(json: json)
    }
    #if DEBUG
    print("Issued API token: \(token.accessToken)")
    #endif
    return token
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
