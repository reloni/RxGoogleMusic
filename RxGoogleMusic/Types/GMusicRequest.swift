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
    let dataRequest: (URLRequest) -> Single<Data>
	let maxResults: Int
	let updatedMin: Date?
	let locale: Locale
	let pageToken: GMusicNextPageToken
	
    init(type: GMusicRequestType, baseUrl: URL, dataRequest: @escaping (URLRequest) -> Single<Data>, maxResults: Int = 25, updatedMin: Date? = nil,
         pageToken: GMusicNextPageToken = .begin, locale: Locale = Locale.current) {
		self.type = type
        self.baseUrl = baseUrl
        self.dataRequest = dataRequest
		self.maxResults = maxResults
		self.updatedMin = updatedMin
		self.locale = locale
		self.pageToken = pageToken
	}
    
    var url: URL {
        let url = URL(baseUrl: baseUrl.appendingPathComponent(type.path).absoluteString, parameters: Dictionary(uniqueKeysWithValues: urlParameters))!
        guard let token = escapedPageToken else { return url }
        return URL(string: "\(url.absoluteString)&start-token=\(token)")!
    }
    
    var escapedPageToken: String? {
        guard case GMusicNextPageToken.token(let token) = pageToken else { return nil }
        return token.addingPercentEncoding(withAllowedCharacters: CharacterSet.nextPageTokenAllowed)
    }
	
    var urlParameters: [(String, String)] {
        return [
            dictionaryPair(key: "dv", value: GMusicConstants.dv),
            dictionaryPair(key: "hl", value: locale.identifier),
            dictionaryPair(key: "max-results", value: maxResults),
            dictionaryPair(key: "prettyPrint", value: false),
            dictionaryPair(key: "tier", value: GMusicConstants.tier),
            dictionaryPair(key: "updated-min", value: updatedMin?.microsecondsSince1970),
            ]
            .compactMap { $0 } + type.urlParameters
    }
}

extension GMusicRequest {
    func dataRequest(withToken token: GMusicToken) -> Single<Data> {
        return gMusicUrlRequest(for: self, with: token)
            |> dataRequest
    }
}
