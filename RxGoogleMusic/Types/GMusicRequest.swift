//
//  GMusicRequest.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

public struct GMusicRequest {
	public let type: GMusicEntityType
	public let maxResults: Int
	public let updatedMin: Date
	public let token: String
	public let locale: Locale
	public let tier: String
	public let pageToken: String?
	
	public init(type: GMusicEntityType, maxResults: Int, updatedMin: Date, token: String, pageToken: String? = nil, locale: Locale = Locale.current, tier: String = "aa") {
		self.type = type
		self.maxResults = maxResults
		self.updatedMin = updatedMin
		self.token = token
		self.locale = locale
		self.tier = tier
		self.pageToken = pageToken
	}
	
	public var urlParameters: [String: String] {
		return ["dv": "3000038001007",
				"hl": locale.identifier,
				"max-results": "\(maxResults)",
			"prettyPrint": "false",
			"tier": tier,
			"updated-min": "\(updatedMin.microsecondsSince1970)"]
	}
	
	public var headers: [String: String] {
		return ["Authorization": "Bearer \(token)"]
	}
	
	var escapedPageToken: String? {
		return pageToken?.addingPercentEncoding(withAllowedCharacters: CharacterSet.nextPageTokenAllowed)
	}
	
	public func withNew(nextPageToken: String) -> GMusicRequest {
		return GMusicRequest(type: type, maxResults: maxResults, updatedMin: updatedMin, token: token, pageToken: nextPageToken, locale: locale, tier: tier)
	}
	
	func buildUrl(for baseUrl: URL) -> URL {
		let url = URL(baseUrl: baseUrl.appendingPathComponent(type.rawValue).absoluteString, parameters: urlParameters)!
		guard let token = escapedPageToken else { return url }
		return URL(string: "\(url.absoluteString)&start-token=\(token)")!
	}
	
	func createGMusicRequest(for baseUrl: URL) -> URLRequest {
		return URLRequest(url: buildUrl(for: baseUrl), headers: headers)
	}
}
