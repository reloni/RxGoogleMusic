//
//  PlaylistEntry.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

public struct GMusicPlaylistEntry: Codable, GMusicEntity {
	public let kind: String
	public let id: UUID
	public let clientId: String?
	public let playlistId: UUID
	public let absolutePosition: String
	public let trackId: String
	public let creationTimestamp: GMusicTimestamp
	public let lastModifiedTimestamp: GMusicTimestamp
	public let deleted: Bool
	public let source: String
	public let track: GMusicTrack?
	
	public static var type: GMusicEntityType = .playlistEntry
}
