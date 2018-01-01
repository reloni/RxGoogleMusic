//
//  GMusicTrack.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

public struct GMusicTrack: Codable {
	let kind: String
	let id: UUID
	let clientId: String
	let creationTimestamp: GMusicTimestamp
	let lastModifiedTimestamp: GMusicTimestamp
	let recentTimestamp: GMusicTimestamp
	let deleted: Bool
	let title: String
	let artist: String
	let composer: String
	let album: String
	let albumArtist: String
	let year: Int
	let trackNumber: Int
	let genre: String
	let durationMillis: String
	let albumArtRef: [GMusicRef]
	let artistArtRef: [GMusicRef]?
	let playCount: Int
	let discNumber: Int
	let rating: String?
	let estimatedSize: String
	let trackType: String
	let storeId: String
	let albumId: String
	let artistId: [String]
	let nid: String
	let explicitType: String
	let lastRatingChangeTimestamp: GMusicTimestamp?
}
