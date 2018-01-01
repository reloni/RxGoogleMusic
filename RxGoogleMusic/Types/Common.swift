//
//  Common.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

enum HttpMethod: String {
	case options = "OPTIONS"
	case get     = "GET"
	case head    = "HEAD"
	case post    = "POST"
	case put     = "PUT"
	case patch   = "PATCH"
	case delete  = "DELETE"
	case trace   = "TRACE"
	case connect = "CONNECT"
}

public enum EntityType: String {
	case track = "tracks"
}

public struct GMusicRequest {
	let type: EntityType
	let maxResults: Int
	let updatedMin: Date
	let token: String
	let locale: Locale
	let tier: String
	
	public init(type: EntityType, maxResults: Int, updatedMin: Date, token: String, locale: Locale = Locale.current, tier: String = "aa") {
		self.type = type
		self.maxResults = maxResults
		self.updatedMin = updatedMin
		self.token = token
		self.locale = locale
		self.tier = tier
	}
	
	func createGMusicRequest(for baseUrl: URL) -> URLRequest {
		let urlParameters: [String: String] = ["dv": "3000038001007",
											   "hl": locale.identifier,
											   "max-results": "\(maxResults)",
			"prettyPrint": "false",
			"tier": tier,
			"updated-min": "\(updatedMin.microsecondsSince1970)"]
		let url = URL(baseUrl: baseUrl.appendingPathComponent(type.rawValue).absoluteString,
					  parameters: urlParameters)!
		
		return URLRequest(url: url, headers: ["Authorization": "Bearer \(token)"])
	}
}

public struct GMusicCollection<T> {
	let kind: String
	let nextPageToken: String?
	let items: [T]
}
