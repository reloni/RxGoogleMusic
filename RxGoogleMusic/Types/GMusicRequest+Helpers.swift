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
        >>> setJson(key: "start-token", value: nextPageToken.rawValue)
        >>> jsonToData
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

func gMusicUrlRequest(for request: GMusicRequest, with token: GMusicToken) -> URLRequest {
    switch request.type {
    case .radioStation, .favorites:
        return request.url
            |> urlRequest
            >>> postJson
            >>> (genericBody(request.maxResults, request.pageToken) |> setBody)
            >>> setAuthorization(token.accessToken)
    case .radioStatioFeed(let stationId):
        return request.url
            |> urlRequest
            >>> postJson
            >>> (radioFeedBody(stationId, request.maxResults) |> setBody)
            >>> setAuthorization(token.accessToken)
    default:
        return request.url
            |> urlRequest
            >>> defaultHeaders
            >>> setAuthorization(token.accessToken)
    }
}


func replaced(nextPageToken: GMusicNextPageToken, in request: GMusicRequest) -> GMusicRequest {
    return GMusicRequest(type: request.type,
                         baseUrl: request.baseUrl,
                         dataRequest: request.dataRequest,
                         maxResults: request.maxResults,
                         updatedMin: request.updatedMin,
                         pageToken: nextPageToken,
                         locale: request.locale)
}
