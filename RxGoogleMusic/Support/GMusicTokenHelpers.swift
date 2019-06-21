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
func gMusicAuthenticationUrl(for jsonRequest: @escaping (URLRequest) -> Single<JSON>, deviceId: UUID) -> Single<URL> {
    return authAdviceRequest(deviceId)
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
        >>> (jsonToToken |> singleMap)
}

// MARK: Refresh token
private func refreshToken(_ token: String, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    return token
        |> tokenRefreshRequest
        >>> jsonRequest
        >>> (jsonToToken |> singleMap)
        >>> singleMap { $0.withNew(refreshToken: token) }}

func refreshToken(_ token: GMusicToken, force: Bool, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    guard let current = token.refreshToken, (token.isTokenExpired || force) else {
        #warning("Maybe should return error if there is no refresh token")
        return .just(token)
    }

    return refreshToken(current, jsonRequest: jsonRequest)
}

// MARK: Issue token
func issueMusicApiToken(withToken token: GMusicToken, deviceId: UUID, jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    return issueMusicApiTokeRequest(token, deviceId)
        |> jsonRequest
        >>> (issueMusicApiToken |> singleMap)
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
func refreshAndIssueTokens(gMusicToken token: GMusicToken, deviceId: UUID, force: Bool,
                           jsonRequest: @escaping (URLRequest) -> Single<JSON>) -> Single<(gMusicToken: GMusicToken, apiToken: GMusicToken)> {
    let refreshToken = RxGoogleMusic.refreshToken(token, force: force, jsonRequest: jsonRequest)
    
    return refreshToken.flatMap { gMusicToken in
            issueMusicApiToken(withToken: gMusicToken, deviceId: deviceId, jsonRequest: jsonRequest).flatMap { apiToken in return .just((gMusicToken, apiToken)) }
    }
}
