//
//  HttpRequest.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02/11/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

// MARK: JSON
private let authAdviceJson =
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

// MARK: Helpers
private func urlRequest(from url: URL) -> URLRequest {
    return URLRequest(url: url)
}

private func setHttpBody(_ body: Data?, to request: URLRequest) -> URLRequest {
    return request
        |> (\.httpBody .~ body)
}

private func setRequest(field: String, value: String?) -> (URLRequest) -> URLRequest {
    return { request in
        return request |> ((\.[field] .~ value) |> property(\.allHTTPHeaderFields) <<< map)
    }
}

// MARK: Request setters
private let guaranteeHeaders: (URLRequest) -> URLRequest = (\.allHTTPHeaderFields .~ [:])
private let postJson: (URLRequest) -> URLRequest = guaranteeHeaders
    <> (\.httpMethod .~ "POST")
    <> setRequest(field: "content-type", value: "application/json")

// MARK: Requests
let authAdviceRequest =
    GMusicConstants.authAdviceUrl
        |> urlRequest
        |> postJson
        |> (authAdviceJson |> (setHttpBody |> curry))
