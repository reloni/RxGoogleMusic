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
	public let locale: Locale
	public let pageToken: GMusicNextPageToken
	
	public init(type: GMusicEntityType, maxResults: Int, updatedMin: Date, pageToken: GMusicNextPageToken = .begin, locale: Locale = Locale.current) {
		self.type = type
		self.maxResults = maxResults
		self.updatedMin = updatedMin
		self.locale = locale
		self.pageToken = pageToken
	}
	
	public var urlParameters: [String: String] {
		return ["dv": GMusicConstants.dv,
				"hl": locale.identifier,
				"max-results": "\(maxResults)",
				"prettyPrint": "false",
				"tier": GMusicConstants.tier,
				"updated-min": "\(updatedMin.microsecondsSince1970)"]
	}
	
	var escapedPageToken: String? {
		guard case GMusicNextPageToken.token(let token) = pageToken else { return nil }
		return token.addingPercentEncoding(withAllowedCharacters: CharacterSet.nextPageTokenAllowed)
	}
	
	public func withNew(nextPageToken: GMusicNextPageToken) -> GMusicRequest {
		return GMusicRequest(type: type, maxResults: maxResults, updatedMin: updatedMin, pageToken: nextPageToken, locale: locale)
	}
	
	func buildUrl(for baseUrl: URL) -> URL {
		let url = URL(baseUrl: baseUrl.appendingPathComponent(type.rawValue).absoluteString, parameters: urlParameters)!
		guard let token = escapedPageToken else { return url }
		return URL(string: "\(url.absoluteString)&start-token=\(token)")!
	}
	
	func createGMusicRequest(for baseUrl: URL, withToken token: GMusicToken) -> URLRequest {
		switch type {
		case .radioStation:
			var request = URLRequest(url: buildUrl(for: baseUrl), headers: Dictionary(dictionaryLiteral: token.header))
			request.httpBody = "{ \"max-results\": \(maxResults) }".data(using: .utf8)
			request.httpMethod = HttpMethod.post.rawValue
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			return request
		default: return URLRequest(url: buildUrl(for: baseUrl), headers: Dictionary(dictionaryLiteral: token.header))
		}
	}
}
