//
//  GMusicArtist.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 08.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

public struct GMusicArtist: Codable {
	enum CodingKeys: String, CodingKey {
		case kind
		case name
		case artistArtRef
		
		case artistArtRefs
		case artistId
		case artistBio
		case albums
		case topTracks
		case relatedArtists = "related_artists"
	}
	public let kind: String
	public let name: String
	public let artistArtRef: URL?
	public let artistArtRefs: [GMusicRef]
	public let artistId: String
	public let artistBio: String?
//	public let artist_bio_attribution
	public let albums: [GMusicAlbum]
	public let topTracks: [GMusicTrack]
	public let relatedArtists: [GMusicArtist]
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		kind = try container.decode(String.self, forKey: .kind)
		name = try container.decode(String.self, forKey: .name)
		artistArtRef = try container.decodeIfPresent(URL.self, forKey: .artistArtRef)
		artistArtRefs = try container.decodeIfPresent([GMusicRef].self, forKey: .artistArtRefs) ?? []
		artistId = try container.decode(String.self, forKey: .artistId)
		artistBio = try container.decodeIfPresent(String.self, forKey: .artistBio)
		albums = try container.decodeIfPresent([GMusicAlbum].self, forKey: .albums) ?? []
		topTracks = try container.decodeIfPresent([GMusicTrack].self, forKey: .topTracks) ?? []
		relatedArtists = try container.decodeIfPresent([GMusicArtist].self, forKey: .relatedArtists) ?? []
	}
}
