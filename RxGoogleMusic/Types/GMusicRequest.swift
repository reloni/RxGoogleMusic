//
//  GMusicRequest.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

struct GMusicRequest {
	let type: GMusicRequestType
    let baseUrl: URL
    let deviceId: UUID
    let dataRequest: (URLRequest) -> Single<Data>
	let maxResults: Int
	let updatedMin: Date?
	let locale: Locale
	let pageToken: GMusicNextPageToken
	
    init(type: GMusicRequestType, baseUrl: URL, deviceId: UUID, dataRequest: @escaping (URLRequest) -> Single<Data>, maxResults: Int = 25, updatedMin: Date? = nil,
         pageToken: GMusicNextPageToken = .begin, locale: Locale = Locale.current) {
		self.type = type
        self.baseUrl = baseUrl
        self.deviceId = deviceId
        self.dataRequest = dataRequest
		self.maxResults = maxResults
		self.updatedMin = updatedMin
		self.locale = locale
		self.pageToken = pageToken
	}
    
    var url: URL {
        let url = URL(baseUrl: baseUrl.appendingPathComponent(type.path).absoluteString,
                   parameters: Dictionary(uniqueKeysWithValues: urlParameters))!
        guard let nextPage = type.nextPageTokenUrlParameter(pageToken) else { return url }
        return url.appendingParameter(key: nextPage.0, rawValue: nextPage.1)!
    }
	
    var urlParameters: [(String, String)] {
        return [
            dictionaryPair(key: "dv", value: GMusicConstants.dv),
            dictionaryPair(key: "hl", value: locale.identifier),
            type.maxResultsUrlParameter(maxResults),
            dictionaryPair(key: "prettyPrint", value: false),
            dictionaryPair(key: "tier", value: GMusicConstants.tier),
            dictionaryPair(key: "updated-min", value: updatedMin?.microsecondsSince1970),
            ]
            .compactMap( { $0 }) + type.urlParameters
    }
}

extension GMusicRequest {
    func dataRequest(withToken token: GMusicToken) -> Single<Data> {
        return self
            |> Environment.current.httpClient.createRequest
            |> setAuthorization(token.accessToken)
            |> setHeader(field: "X-Device-ID", value: "ios:\(deviceId.uuidString)")
            |> dataRequest
    }
    
    func replaced(nextPageToken: GMusicNextPageToken) -> GMusicRequest {
        return GMusicRequest(type: self.type,
                             baseUrl: self.baseUrl,
                             deviceId: self.deviceId,
                             dataRequest: self.dataRequest,
                             maxResults: self.maxResults,
                             updatedMin: self.updatedMin,
                             pageToken: nextPageToken,
                             locale: self.locale)
    }
}
