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
	let pageToken: String?
	
	public init(type: EntityType, maxResults: Int, updatedMin: Date, token: String, pageToken: String? = nil, locale: Locale = Locale.current, tier: String = "aa") {
		self.type = type
		self.maxResults = maxResults
		self.updatedMin = updatedMin
		self.token = token
		self.locale = locale
		self.tier = tier
		self.pageToken = pageToken
	}
	
	func buildUrl(for baseUrl: URL) -> URL {
		return URL(baseUrl: baseUrl.appendingPathComponent(type.rawValue).absoluteString, parameters: urlParameters)!
	}
	
	var urlParameters: [String: String] {
		return ["dv": "3000038001007", "hl": locale.identifier, "max-results": "\(maxResults)",
			"prettyPrint": "false", "tier": tier, "updated-min": "\(updatedMin.microsecondsSince1970)"]
	}
	
	var headers: [String: String] {
		return ["Authorization": "Bearer \(token)", "start-token": pageToken ?? ""].filter { $0.value != "" }
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
	
	let kind: String
	let nextPageToken: String?
	let items: [T]
	
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
	let kind: String
	let url: URL
	let aspectRatio: String
	let autogen: Bool
}

public struct GMusicTimestamp: Codable, CustomDebugStringConvertible {
	let value: Date
	let rawValue: String
	
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
