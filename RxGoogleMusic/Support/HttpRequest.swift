//
//  HttpRequest.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02/11/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

//// MARK: Body
private let authAdviceBody =
    """
        {
        "report_user_id": "true",
        "system_version": "\(GMusicConstants.systemVersion)",
        "app_version": "1.0",
        "user_id": [],
        "request_trigger": "ADD_ACCOUNT",
        "lib_ver": "3.2",
        "package_name": "\(GMusicConstants.packageName)",
        "supported_service": ["uca"],
        "redirect_uri": "\(GMusicConstants.redirectUri)",
        "device_name": "\(GMusicConstants.deviceModel)",
        "fast_setup": "true",
        "mediator_client_id": "\(GMusicConstants.clientId)",
        "device_id": "\(GMusicConstants.deviceId)",
        "hl": "\(Locale.current.identifier)",
        "client_id": "\(GMusicConstants.clientIdLong)"
        }
        """.data(using: .utf8)

private let tokenExchangeBody = { (code: String) in
    return """
        grant_type=\(GrantType.authorizationCode.rawValue)&
        code=\(code)&
        client_id=\(GMusicConstants.clientId)&
        client_secret=\(GMusicConstants.clientSecret)&
        scope=\(Scope.oauthLogin.rawValue)
        """
        .replacingOccurrences(of: "\n", with: "")
        .data(using: .utf8)
}

// MARK: Helpers
private func urlRequest(from url: URL) -> URLRequest {
    return URLRequest(url: url)
}

private func setBody(_ body: Data?) -> (URLRequest) -> URLRequest {
    return { request in
        return request |> (\.httpBody .~ body)
    }
}

private func setMethod(_ method: HttpMethod) -> (URLRequest) -> URLRequest {
    return { request in
        return request |> (\.httpMethod .~ (method.rawValue as String?))
    }
}

private func setHeader(field: String, value: String?) -> (URLRequest) -> URLRequest {
    return { request in
        return request |> ((\.[field] .~ value) |> property(\.allHTTPHeaderFields) <<< map)
    }
}

// MARK: Request setters
private let guaranteeHeaders: (URLRequest) -> URLRequest = (\.allHTTPHeaderFields .~ [:])
private let postHeader: (URLRequest) -> URLRequest = guaranteeHeaders
    <> setMethod(.post)
private let postJson: (URLRequest) -> URLRequest = postHeader
    <> setHeader(field: "content-type", value: "application/json")
private let postUrlEncoded: (URLRequest) -> URLRequest = postHeader
    <> setHeader(field: "content-type", value: "application/x-www-form-urlencoded")

// MARK: Requests
let authAdviceRequest =
    GMusicConstants.authAdviceUrl
        |> urlRequest
        |> postJson
        |> (authAdviceBody |> setBody)

let tokenExchangeRequest = { (code: String) in
    return GMusicConstants.tokenUrl
        |> urlRequest
        |> postUrlEncoded
        |> (code |> tokenExchangeBody |> setBody)
}
