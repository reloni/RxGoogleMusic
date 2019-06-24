//
//  GMusicRequest+Helpers.swift
//  RxGoogleMusicTests
//
//  Created by Anton Efimenko on 17/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

private let genericBody = { (maxResults: Int, nextPageToken: GMusicNextPageToken) in
    return JSON()
        |> setJson(key: "max-results", value: maxResults)
        <> setJson(key: "start-token", value: nextPageToken.rawValue)
        |> jsonToData
}

private let radioFeedBody = { (radioId: String, numEntries: Int) in
    return
        """
        {
            "contentFilter": "1",
            "stations": [
                {
                    "radioId": "\(radioId)",
                    "numEntries": \(numEntries),
                    "recentlyPlayed": []
                }
            ]
        }
        """.data(using: .utf8)
}

func createUrlRequest(for request: GMusicRequest) -> URLRequest {
    switch request.type {
    case .radioStation, .favorites:
        return request.url
            |> urlRequest
            |> defaultHeaders
            |> setHeaders(request.headers)
            |> postJson
            <> (genericBody(request.maxResults, request.pageToken) |> setBody)
    case .radioStatioFeed(let stationId):
        return request.url
            |> urlRequest
            |> defaultHeaders
            |> setHeaders(request.headers)
            |> postJson
            <> (radioFeedBody(stationId, request.maxResults) |> setBody)
    default:
        return request.url
            |> urlRequest
            |> defaultHeaders
            |> setHeaders(request.headers)
    }
}
