//
//  HttpRequest.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02/11/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

//// MARK: Body
private let authAdviceBody = { (deviceId: UUID) in
    return
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
            "device_id": "\(deviceId.uuidString)",
            "hl": "\(Locale.current.identifier)",
            "client_id": "\(GMusicConstants.clientIdLong)"
            }
            """.data(using: .utf8)
}
private let tokenExchangeBody = { (code: String) in
    return
        """
        grant_type=\(GrantType.authorizationCode.rawValue)&
        code=\(code)&
        client_id=\(GMusicConstants.clientId)&
        client_secret=\(GMusicConstants.clientSecret)&
        scope=\(Scope.oauthLogin.rawValue)
        """
        .replacingOccurrences(of: "\n", with: "")
        .data(using: .utf8)
}

private let tokenRefreshBody = { (refreshToken: String) in
    return
        """
        grant_type=\(GrantType.refreshToken.rawValue)&
        client_id=\(GMusicConstants.clientId)&
        client_secret=\(GMusicConstants.clientSecret)&
        refresh_token=\(refreshToken)
        """
        .replacingOccurrences(of: "\n", with: "")
        .data(using: .utf8)
}

private let issueMusicApiTokenBody = { (deviceId: UUID) in
    """
    client_id=\(GMusicConstants.clientIdLong)&
    app_id=\(GMusicConstants.packageName)&
    device_id=\(deviceId.uuidString)&
    hl=\(Locale.current.identifier)&
    response_type=token&
    scope=\(Scope.skyjam.rawValue) \(Scope.supportcontent.rawValue)
    """
    .replacingOccurrences(of: "\n", with: "")
    .data(using: .utf8)
}

// MARK: Requests
let authAdviceRequest = { (deviceId: UUID) in
    GMusicConstants.authAdviceUrl
        |> urlRequest
        |> postJson
        <> (authAdviceBody(deviceId) |> setBody)
}

let tokenExchangeRequest = { (code: String) in
    return GMusicConstants.tokenUrl
        |> urlRequest
        |> postUrlEncoded
        <> (code |> tokenExchangeBody |> setBody)
}

let tokenRefreshRequest = { (refreshToken: String) in
    return GMusicConstants.tokenUrl
        |> urlRequest
        |> postUrlEncoded
        <> (refreshToken |> tokenRefreshBody |> setBody)
}

let issueMusicApiTokeRequest = { (token: GMusicToken, deviceId: UUID) in
    return GMusicConstants.issueTokenUrl
        |> urlRequest
        |> postUrlEncoded
        <> setAuthorization(token.accessToken)
        <> (issueMusicApiTokenBody(deviceId) |> setBody)
}

let loginPageRequest = { (url: URL, deviceId: UUID) in
    return url
        |> urlRequest
        |> setHeader(field: "X-IOS-Device-ID", value: deviceId.uuidString)
        <> setHeader(field: "X-Browser-View", value: "embedded")
}
