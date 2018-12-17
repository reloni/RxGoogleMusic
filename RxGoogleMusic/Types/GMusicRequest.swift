//
//  GMusicRequest.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

struct GMusicRequest {
	let type: GMusicRequestPath
    let baseUrl: URL
    let dataRequest: (URLRequest) -> Single<Data>
	let maxResults: Int
	let updatedMin: Date?
	let locale: Locale
	let pageToken: GMusicNextPageToken
	let nid: String?
	let includeAlbums: Bool?
	let includeBio: Bool?
	let numRelatedArtists: Int?
	let numTopTracks: Int?
	let includeDescription: Bool?
	let includeTracks: Bool?
	
    init(type: GMusicRequestPath, baseUrl: URL, dataRequest: @escaping (URLRequest) -> Single<Data>, maxResults: Int = 25, updatedMin: Date? = nil,
         pageToken: GMusicNextPageToken = .begin, locale: Locale = Locale.current, nid: String? = nil, includeAlbums: Bool? = nil, includeBio: Bool? = nil,
				numRelatedArtists: Int? = nil, numTopTracks: Int? = nil, includeDescription: Bool? = nil, includeTracks: Bool? = nil) {
		self.type = type
        self.baseUrl = baseUrl
        self.dataRequest = dataRequest
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
    
    var url: URL {
        let url = URL(baseUrl: baseUrl.appendingPathComponent(type.path).absoluteString, parameters: urlParameters)!
        guard let token = escapedPageToken else { return url }
        return URL(string: "\(url.absoluteString)&start-token=\(token)")!
    }
    
    var escapedPageToken: String? {
        guard case GMusicNextPageToken.token(let token) = pageToken else { return nil }
        return token.addingPercentEncoding(withAllowedCharacters: CharacterSet.nextPageTokenAllowed)
    }
	
	var urlParameters: [String: String] {
        let dictionaryValues: [(String, String)] = [
            dictionaryPair(key: "dv", value: GMusicConstants.dv),
            dictionaryPair(key: "hl", value: locale.identifier),
            dictionaryPair(key: "max-results", value: maxResults),
            dictionaryPair(key: "prettyPrint", value: false),
            dictionaryPair(key: "tier", value: GMusicConstants.tier),
            dictionaryPair(key: "updated-min", value: updatedMin?.microsecondsSince1970),
            dictionaryPair(key: "nid", value: nid),
            dictionaryPair(key: "include-albums", value: includeAlbums),
            dictionaryPair(key: "include-bio", value: includeBio),
            dictionaryPair(key: "num-related-artists", value: numRelatedArtists),
            dictionaryPair(key: "num-top-tracks", value: numTopTracks),
            dictionaryPair(key: "include-description", value: includeDescription),
            dictionaryPair(key: "include-tracks", value: includeTracks)
            ].compactMap { $0 }
		return Dictionary.init(uniqueKeysWithValues: dictionaryValues)
	}
}

extension GMusicRequest {
    func dataRequest(withToken token: GMusicToken) -> Single<Data> {
        return gMusicUrlRequest(for: self, with: token)
            |> dataRequest
    }
}
