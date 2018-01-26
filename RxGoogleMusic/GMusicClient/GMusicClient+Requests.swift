//
//  GMusicClient+Requests.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

public extension GMusicClient {
	func tracks(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, pageToken: GMusicNextPageToken = .begin, recursive: Bool = false) -> Observable<GMusicCollection<GMusicTrack>> {
		return entityCollection(updatedMin: updatedMin, maxResults: maxResults, pageToken: pageToken, recursive: recursive)
	}
	
	func playlists(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, pageToken: GMusicNextPageToken = .begin, recursive: Bool = false) -> Observable<GMusicCollection<GMusicPlaylist>> {
		return entityCollection(updatedMin: updatedMin, maxResults: maxResults, pageToken: pageToken, recursive: recursive)
	}
	
	func playlistEntries(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, pageToken: GMusicNextPageToken = .begin, recursive: Bool = false) -> Observable<GMusicCollection<GMusicPlaylistEntry>> {
		return entityCollection(updatedMin: updatedMin, maxResults: maxResults, pageToken: pageToken, recursive: recursive)
	}
	
	func radioStations(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, pageToken: GMusicNextPageToken = .begin, recursive: Bool = false) -> Observable<GMusicCollection<GMusicRadioStation>> {
		return entityCollection(updatedMin: updatedMin, maxResults: maxResults, pageToken: pageToken, recursive: recursive)
	}
}
