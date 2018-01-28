//
//  GMusicPlaylist.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

public struct GMusicPlaylist: Codable, GMusicEntity {
	public let kind: String
	public let id: UUID
	public let clientId: String?
	public let creationTimestamp: GMusicTimestamp
	public let lastModifiedTimestamp: GMusicTimestamp
	public let recentTimestamp: GMusicTimestamp
	public let deleted: Bool
	public let name: String
	public let type: String
	public let shareToken: String
	public let ownerName: String
	public let ownerProfilePhotoUrl: URL?
	public let accessControlled: Bool
	public let description: String?
	
	public static var collectionRequestPath: GMusicRequestPath = .playlist
}
