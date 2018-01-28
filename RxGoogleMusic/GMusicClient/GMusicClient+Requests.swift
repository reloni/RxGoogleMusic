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
	
	func favorites(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, pageToken: GMusicNextPageToken = .begin, recursive: Bool = false) -> Observable<GMusicCollection<GMusicTrack>> {
		let request = GMusicRequest(type: .favorites, maxResults: maxResults, updatedMin: updatedMin, pageToken: pageToken, locale: locale)
		return entityCollection(request: request, recursive: recursive)
	}
	
	func artist(_ id: String, includeAlbums: Bool = false, includeBio: Bool = false, numRelatedArtists: Int? = nil, numTopTracks: Int? = nil) -> Observable<GMusicArtist> {
		let request = GMusicRequest(type: .artist, locale: locale, nid: id, includeAlbums: includeAlbums, includeBio: includeBio,
									numRelatedArtists: numRelatedArtists, numTopTracks: numTopTracks)
		return entityRequest(request)
	}
}
