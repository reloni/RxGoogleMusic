//
//  Common.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit

typealias JSON = [String: Any]

struct GMusicConstants {
	static let apiBaseUrl = URL(string: "https://mclients.googleapis.com/sj/v2.5")!
	static let tokenUrl = URL(string: "https://www.googleapis.com/oauth2/v4/token")!
	static let issueTokenUrl = URL(string: "https://www.googleapis.com/oauth2/v2/IssueToken")!
	static let authAdviceUrl = URL(string: "https://www.googleapis.com/oauth2/v3/authadvice")!
	static let clientId = "936475272427.apps.googleusercontent.com"
	static let clientIdLong = "228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o.apps.googleusercontent.com"
	static let clientSecret = "KWsJlkaMn1jGLxQpWxMnOox-"
	static let redirectUri = "com.google.sso.228293309116-bs4u7ofpm4p6p6da7i1jkan3hfr6h38o:/authCallback"
	static let packageName = "com.google.PlayMusic"
	
	static let systemVersion = UIDevice.current.systemVersion
	static let deviceModel = UIDevice.current.model
	static let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
}

enum Scope: String {
	case oauthLogin = "https://www.google.com/accounts/OAuthLogin"
	case skyjam = "https://www.googleapis.com/auth/skyjam"
	case supportcontent = "https://www.googleapis.com/auth/supportcontent"
}

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

enum GrantType: String {
	case authorizationCode = "authorization_code"
	case refreshToken = "refresh_token"
}

public struct GMusicToken {
	public let accessToken: String
	public let expiresIn: Int?
	public let refreshToken: String?
	public let expiresAt: Date?
	var isTokenExpired: Bool {
		return expiresAt == nil ? true : expiresAt! < Date()
	}
	
	public init(accessToken: String, expiresIn: Int?, refreshToken: String?) {
		self.accessToken = accessToken
		self.expiresIn = expiresIn
		self.refreshToken = refreshToken
		
		self.expiresAt = expiresIn == nil ? nil : Date().addingTimeInterval(Double(expiresIn!))
		
	}
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
