//
//  GMusicTrack.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

public struct GMusicTrack: Codable, Equatable {
    /// Workaround in order to be able to identify track
    public let automaticId = UUID()
	public let kind: String
	public let id: UUID?
	public let clientId: String?
	public let creationTimestamp: GMusicTimestamp?
	public let lastModifiedTimestamp: GMusicTimestamp?
	public let recentTimestamp: GMusicTimestamp?
	public let deleted: Bool?
	public let title: String
	public let artist: String
	public let composer: String?
	public let album: String
	public let albumArtist: String
	public let year: Int?
	public let trackNumber: Int
	public let genre: String?
	public let durationMillis: String
	public let albumArtRef: [GMusicRef]?
	public let artistArtRef: [GMusicRef]?
	public let playCount: Int?
	public let discNumber: Int
	public let rating: String?
	public let estimatedSize: String?
	public let trackType: String?
	public let storeId: String?
	public let albumId: String?
	public let artistId: [String]?
	public let nid: String?
	public let explicitType: String?
	public let lastRatingChangeTimestamp: GMusicTimestamp?
	public let trackAvailableForSubscription: Bool?
	public let trackAvailableForPurchase: Bool?
	public let albumAvailableForPurchase: Bool?
    
    var identifier: String? {
        return storeId ?? nid
    }
}

public extension GMusicTrack {
    var duration: TimeInterval {
        return TimeInterval(durationMillis).map { $0 / 1000 } ?? 0
    }
}

extension GMusicTrack: GMusicEntity {
    static var collectionRequestPath: GMusicRequestType = .track
}
