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
func tokenRequestFromCode(_ code: String) -> URLRequest {
    return code |> URLRequest.codeForTokenExchangeRequest
}

func refreshTokenRequest(from refreshToken: String) -> URLRequest {
    return refreshToken |> URLRequest.tokenRefreshRequest
}

func tokenJsonToObject(_ request: Single<JSON>) -> Single<GMusicToken> {
    return request.flatMap(tokenJsonToObject)
}

func tokenJsonToObject(_ json: JSON) -> Single<GMusicToken> {
    guard let token = GMusicToken(json: json) else {
        return .error(GMusicError.unableToRetrieveAccessToken(json: json))
    }
    return .just(token)
}

// MARK: Authentication URL
func gMusicAuthenticationUrl(_ request: URLRequest, in session: URLSession) -> Single<URL> {
    return request
        |> (session |> jsonRequest)
        |> gMusicAuthenticationUrl
}

func gMusicAuthenticationUrl(for session: URLSession) -> Single<URL> {
    return gMusicAuthenticationUrl(URLRequest.authAdviceRequest(), in: session)
}

func gMusicAuthenticationUrl(from request: Single<JSON>) -> Single<URL> {
    return request.flatMap { json -> Single<URL> in
        guard let uri = URL(string: json["uri"] as? String ?? "") else {
            return .error(GMusicError.unableToRetrieveAuthenticationUri(json: json))
        }
        return .just(uri)
    }
}

// MARK: Token exchange
func exchangeOAuthCodeForToken(code: String, session: URLSession) -> Single<GMusicToken> {
    return code
        |> tokenRequestFromCode
        |> (session |> jsonRequest)
        |> tokenJsonToObject
}

let sessionExchangeOAuthCodeForToken = exchangeOAuthCodeForToken
    |> curry
    |> flip


// Mark: Refresh token
func refreshToken(_ token: String, request: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    return token
        |> refreshTokenRequest
        |> request
        |> tokenJsonToObject
}


func refreshToken(_ token: GMusicToken, force: Bool, request: @escaping (URLRequest) -> Single<JSON>) -> Single<GMusicToken> {
    guard let current = token.refreshToken, (token.isTokenExpired || force) else {
        // TODO: Maybe should return error if there is no refresh token
        return .just(token)
    }

    return refreshToken(current, request: request)
}
