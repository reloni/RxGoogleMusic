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

public protocol GMusicEntity {
	static var collectionRequestPath: GMusicRequestPath { get }
}

public enum GMusicRequestPath: String {
	case track = "tracks"
	case playlist = "playlists"
	case playlistEntry = "plentries"
	case radioStation = "radio/station"
	case favorites = "ephemeral/top"
	case artist = "fetchartist"
	case album = "fetchalbum"
}

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
	static let dv = "3000038001007" // required magic paramerer ¯\_(ツ)_/¯
	static let tier = "aa" // another requered parameter
	
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

public enum GMusicError: Error {
	case jsonParseError(Error)
	case unknownJsonStructure
	case urlRequestError(response: URLResponse, data: Data?)
	case urlRequestLocalError(Error)
	case unableToRetrieveAccessToken(json: [String: Any])
	case unableToRetrieveAuthenticationUri(json:[String: Any])
	case unknown(Error)
}

public struct GMusicToken {
	public let accessToken: String
	public let expiresIn: Int?
	public let refreshToken: String?
	public let expiresAt: Date?
	var isTokenExpired: Bool {
		return expiresAt == nil ? true : expiresAt! < Date()
	}
	var header: (String, String) {
		return ("Authorization", "Bearer \(accessToken)")
	}
	
	init?(json: JSON) {
		guard let at = json["access_token"] as? String, at.count > 0 else { return nil }
		self.init(accessToken: at,
				  expiresIn: json["expires_in"] as? Int,
				  refreshToken: json["refresh_token"] as? String)
	}
	
	init?(apiTokenJson json: JSON) {
		guard let at = json["token"] as? String, at.count > 0 else { return nil }
		self.init(accessToken: at,
				  expiresIn: Int(json["expiresIn"] as? String ?? ""),
				  refreshToken: nil)
	}

	
	public init(accessToken: String, expiresIn: Int?, refreshToken: String?) {
		self.accessToken = accessToken
		self.expiresIn = expiresIn
		self.refreshToken = refreshToken
		
		self.expiresAt = expiresIn == nil ? nil : Date().addingTimeInterval(Double(expiresIn!))
		
	}
}

public enum GMusicNextPageToken {
	case begin
	case token(String)
	case end
}

public struct GMusicCollection<T: Codable>: Decodable {
	enum CodingKeys: String, CodingKey {
		case kind
		case nextPageToken
		case data
	}
	
	enum NestedDataKeys: String, CodingKey {
		case items
	}
	
	public let kind: String
	public let nextPageToken: GMusicNextPageToken
	public let items: [T]
	
	public init(kind: String, nextPageToken: GMusicNextPageToken = .begin, items: [T] = []) {
		self.kind = kind
		self.nextPageToken = nextPageToken
		self.items = items
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		kind = try container.decode(String.self, forKey: .kind)
		if let token = try container.decodeIfPresent(String.self, forKey: .nextPageToken) {
			nextPageToken = .token(token)
		} else {
			nextPageToken = .end
		}
		
		let nestedContainer = try? container.nestedContainer(keyedBy: NestedDataKeys.self, forKey: .data)
		items = try nestedContainer?.decodeIfPresent([T].self, forKey: .items) ?? []
	}
	
	public func appended(nextCollection: GMusicCollection<T>) -> GMusicCollection<T> {
		let newItems = items + nextCollection.items
		return GMusicCollection(kind: nextCollection.kind, nextPageToken: nextCollection.nextPageToken, items: newItems)
	}
}

public struct GMusicRef: Codable {
	public let kind: String
	public let url: URL
	public let aspectRatio: String?
	public let autogen: Bool?
}

public struct GMusicAlbum: Codable {
	public let kind: String
	public let name: String
	public let albumArtist: String
	public let albumArtRef: URL?
	public let albumId: String
	public let artist: String
	public let artistId: [String]?
	public let year: Int?
	public let explicitType: String?
	//	public let description_attribution
	public let tracks: [GMusicTrack]?
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
