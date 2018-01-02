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

public enum GMusicEntityType: String {
	case track = "tracks"
	case playlist = "playlists"
	case playlistEntry = "plentries"
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
		let nestedContainer = try? container.nestedContainer(keyedBy: NestedDataKeys.self, forKey: .data)
		items = try nestedContainer?.decodeIfPresent([T].self, forKey: .items) ?? []
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
