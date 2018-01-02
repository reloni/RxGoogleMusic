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
	public let type: EntityType
	public let maxResults: Int
	public let updatedMin: Date
	public let token: String
	public let locale: Locale
	public let tier: String
	public let pageToken: String?
	
	public init(type: EntityType, maxResults: Int, updatedMin: Date, token: String, pageToken: String? = nil, locale: Locale = Locale.current, tier: String = "aa") {
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

public struct GMusicCollection<T: Codable>: Codable {
	enum CodingKeys: String, CodingKey {
		case kind
		case nextPageToken
		case data
	}
	
	enum NestedDataKeys: String, CodingKey {
		case items
	}
	
	public let kind: String
	public let nextPageToken: String?
	public let items: [T]
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		kind = try container.decode(String.self, forKey: .kind)
		nextPageToken = try container.decodeIfPresent(String.self, forKey: .nextPageToken)
		let nestedContainer = try container.nestedContainer(keyedBy: NestedDataKeys.self, forKey: .data)
		items = try nestedContainer.decode([T].self, forKey: .items)
	}
	
	public func encode(to encoder: Encoder) throws {
		fatalError("Not implemented")
	}
}

public struct GMusicRef: Codable {
	public let kind: String
	public let url: URL
	public let aspectRatio: String?
	public let autogen: Bool?
}

public struct GMusicTimestamp: Codable, CustomDebugStringConvertible {
	public let value: Date
	public let rawValue: String
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		
		let rawValue = try container.decode(String.self)
		guard let timeStamp = UInt64(rawValue) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to deserialize timestamp")
		}
		
		self.rawValue = rawValue
		value = Date(microsecondsSince1970: timeStamp)
	}
	
	public var debugDescription: String {
		return value.debugDescription
	}
}
