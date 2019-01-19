//
//  Common.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif
typealias JSON = [String: Any]

protocol GMusicEntity {
    static var collectionRequestPath: GMusicRequestType { get }
}

public enum StreamQuality: String {
    case medium = "med"
    case high = "hi"
}

public enum NetworkType: String {
    case wifi = "wifi"
}

public enum AudioFormat: String {
    case mp4aaclc = "fmp4_aac_lc"
    case mp4aacv1 = "fmp4_he_aac_v1"
    
    // iOS
    //case mp4aac = "fmp4_aac"
    //case mp3 = "mp3"
}

public enum AudioQuality: Int {
    case high = 512
    case medium = 320
}

enum GMusicRequestType {
    case track
	case playlist
	case playlistEntry
	case radioStation
	case favorites
    case artist(id: String, numRelatedArtists: Int, numTopTracks: Int, includeAlbums: Bool, includeBio: Bool)
    case album(id: String, includeDescription: Bool, includeTracks: Bool)
    case radioStatioFeed(statioId: String)
    case stream(trackId: String, quality: StreamQuality)
    
    var path: String {
        switch self {
        case .track: return "/sj/v2.5/tracks"
        case .playlist: return "/sj/v2.5/playlists"
        case .playlistEntry: return "/sj/v2.5/plentries"
        case .radioStation: return "/sj/v2.5/radio/station"
        case .favorites: return "/sj/v2.5/ephemeral/top"
        case .artist: return "/sj/v2.5/fetchartist"
        case .album: return "/sj/v2.5/fetchalbum"
        case .radioStatioFeed: return "/sj/v2.5/radio/stationfeed"
        case .stream: return "music/mplay"
        }
    }
    
    var urlParameters: [(String, String)] {
        switch self {
        case let .album(id, includeDescription, includeTracks):
            return [("nid", id), ("include-description", "\(includeDescription)"), ("include-tracks", "\(includeTracks)")]
        case let .artist(id, numRelatedArtists, numTopTracks, includeAlbums, includeBio):
            return [("nid", id), ("num-related-artists", "\(numRelatedArtists)"),
                    ("num-top-tracks", "\(numTopTracks)"), ("include-albums", "\(includeAlbums)"), ("include-bio", "\(includeBio)")]
        case let .stream(trackId, quality):
            let (sig, slt) = Hmac.sign(string: trackId, salt: Hmac.currentSalt)
            
            // mjck if trackID started with T or D,
            // songid instead
            let formats = [AudioFormat.mp4aaclc.rawValue, AudioFormat.mp4aacv1.rawValue].joined(separator: ",")
            return [("mjck", trackId), ("sig", sig), ("slt", slt), ("opt", quality.rawValue), ("ppf", formats), ("upf", "mp3"),
                    ("net", NetworkType.wifi.rawValue), ("targetkbps", "\(AudioQuality.medium.rawValue)"), ("p", "1"), ("pt", "e"), ("adaptive", "false")]
        case .favorites, .radioStation, .radioStatioFeed, .playlist, .playlistEntry, .track:
            return []
        }
    }
    
    func maxResultsUrlParameter(_ value: Int) -> (String, String)? {
        switch self {
        case .track, .playlist, .playlistEntry: return ("max-results", "\(value)")
        case .album, .radioStation, .radioStatioFeed, .stream, .favorites, .artist: return nil
        }
    }
    
    func nextPageTokenUrlParameter(_ value: GMusicNextPageToken) -> (String, String)? {
        switch self {
        case .track, .playlist, .playlistEntry:
            guard let token = value.escapedValue else { return nil }
            return ("start-token", "\(token)")
        case .album, .radioStation, .radioStatioFeed, .stream, .favorites, .artist: return nil
        }
    }
}

struct GMusicConstants {
	static let apiBaseUrl = URL(string: "https://mclients.googleapis.com")!
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
	
    static let deviceModel = HardwareType.current.model
    static let systemVersion = HardwareType.current.osVersion
    static let deviceId = UUID().uuidString
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
    case clientDisposed
	case jsonParseError(Error)
	case unknownJsonStructure
    case emptyDataResponse
	case urlRequestError(response: URLResponse, data: Data?)
	case urlRequestLocalError(Error)
	case unableToRetrieveAccessToken(json: [String: Any])
	case unableToRetrieveAuthenticationUri(json:[String: Any])
	case unknown(Error)
}

public struct GMusicToken {
	public let accessToken: String
	public let refreshToken: String?
	public let expiresAt: Date?
	public var isTokenExpired: Bool {
		return expiresAt == nil ? true : expiresAt! < Date()
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
        self.init(accessToken: accessToken,
                  expiresAt: expiresIn == nil ? nil : Date().addingTimeInterval(Double(expiresIn!)),
                  refreshToken: refreshToken)
	}
    
    public init(accessToken: String, expiresAt: Date?, refreshToken: String?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }
}

extension GMusicToken {
    func withNew(refreshToken token: String?) -> GMusicToken {
        return GMusicToken(accessToken: accessToken, expiresAt: expiresAt, refreshToken: token)
    }
}

public enum GMusicNextPageToken {
	case begin
	case token(String)
	case end
    
    var escapedValue: String? {
        guard case GMusicNextPageToken.token(let token) = self else { return nil }
        return token.addingPercentEncoding(withAllowedCharacters: CharacterSet.nextPageTokenAllowed)
    }
    
    var rawValue: String? {
        guard case GMusicNextPageToken.token(let token) = self else { return nil }
        return token
    }
}

public struct GMusicCollection<T: Codable>: Decodable {
    enum GMusicCollectionNestedKeys: String, CodingKey {
        case items
        case stations
        
        static func nestedKey(forKind kind: String) -> GMusicCollectionNestedKeys {
            switch kind {
            case "sj#radioFeed":
                return GMusicCollectionNestedKeys.stations
            default:
                return GMusicCollectionNestedKeys.items
            }
        }
    }
    
	enum CodingKeys: String, CodingKey {
		case kind
		case nextPageToken
		case data
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
		
        let nested = GMusicCollectionNestedKeys.nestedKey(forKind: kind)
		let nestedContainer = try? container.nestedContainer(keyedBy: GMusicCollectionNestedKeys.self, forKey: .data)
		items = try nestedContainer?.decodeIfPresent([T].self, forKey: nested) ?? []
	}
	
	public func appended(nextCollection: GMusicCollection<T>) -> GMusicCollection<T> {
		let newItems = items + nextCollection.items
		return GMusicCollection(kind: nextCollection.kind, nextPageToken: nextCollection.nextPageToken, items: newItems)
	}
}

public struct GMusicRef: Codable, Equatable {
	public let kind: String
	public let url: URL
	public let aspectRatio: String?
	public let autogen: Bool?
}

public struct GMusicAlbum: Codable, Equatable {
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

public struct GMusicTimestamp: Codable, CustomDebugStringConvertible, Equatable {
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
