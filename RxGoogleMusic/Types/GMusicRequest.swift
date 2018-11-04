//
//  GMusicRequest.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

public struct GMusicRequest {
	public let type: GMusicRequestPath
	public let maxResults: Int?
	public let updatedMin: Date?
	public let locale: Locale
	public let pageToken: GMusicNextPageToken
	public let nid: String?
	public let includeAlbums: Bool?
	public let includeBio: Bool?
	public let numRelatedArtists: Int?
	public let numTopTracks: Int?
	public let includeDescription: Bool?
	public let includeTracks: Bool?
	
	public init(type: GMusicRequestPath, maxResults: Int? = nil, updatedMin: Date? = nil, pageToken: GMusicNextPageToken = .begin,
				locale: Locale = Locale.current, nid: String? = nil, includeAlbums: Bool? = nil, includeBio: Bool? = nil,
				numRelatedArtists: Int? = nil, numTopTracks: Int? = nil,
				includeDescription: Bool? = nil, includeTracks: Bool? = nil) {
		self.type = type
		self.maxResults = maxResults
		self.updatedMin = updatedMin
		self.locale = locale
		self.pageToken = pageToken
		self.nid = nid
		self.includeAlbums = includeAlbums
		self.includeBio = includeBio
		self.numRelatedArtists = numRelatedArtists
		self.numTopTracks = numTopTracks
		self.includeDescription = includeDescription
		self.includeTracks = includeTracks
	}
	
	public var urlParameters: [String: String] {
        let dictionaryValues: [(String, String)] = [
            getUrlParameter(key: "dv", value: GMusicConstants.dv),
            getUrlParameter(key: "hl", value: locale.identifier),
            getUrlParameter(key: "max-results", value: maxResults),
            getUrlParameter(key: "prettyPrint", value: false),
            getUrlParameter(key: "tier", value: GMusicConstants.tier),
            getUrlParameter(key: "updated-min", value: updatedMin?.microsecondsSince1970),
            getUrlParameter(key: "nid", value: nid),
            getUrlParameter(key: "include-albums", value: includeAlbums),
            getUrlParameter(key: "include-bio", value: includeBio),
            getUrlParameter(key: "num-related-artists", value: numRelatedArtists),
            getUrlParameter(key: "num-top-tracks", value: numTopTracks),
            getUrlParameter(key: "include-description", value: includeDescription),
            getUrlParameter(key: "include-tracks", value: includeTracks)
            ].compactMap { $0 }
		return Dictionary.init(uniqueKeysWithValues: dictionaryValues)
	}
	
	func getUrlParameter<T>(key: String, value: T?) -> (String, String)? {
		guard let v = value else { return nil }
		return (key, String(describing: v))
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
		case .radioStation, .favorites:
			var request = URLRequest(url: buildUrl(for: baseUrl), headers: Dictionary(dictionaryLiteral: token.header))
			request.httpBody = "{ \"max-results\": \(maxResults ?? 0) }".data(using: .utf8)
			request.httpMethod = HttpMethod.post.rawValue
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			return request
		default: return URLRequest(url: buildUrl(for: baseUrl), headers: Dictionary(dictionaryLiteral: token.header))
		}
	}
}
