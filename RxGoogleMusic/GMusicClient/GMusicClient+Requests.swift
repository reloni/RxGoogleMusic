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
	func tracks(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, recursive: Bool = false) -> Observable<GMusicCollection<GMusicTrack>> {
		let request = GMusicRequest(type: .track, maxResults: maxResults, updatedMin: updatedMin, locale: locale)
		return collectionRequest(request, recursive: recursive)
	}
	
	func playlists(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, recursive: Bool = false) -> Observable<GMusicCollection<GMusicPlaylist>> {
		let request = GMusicRequest(type: .playlist, maxResults: maxResults, updatedMin: updatedMin, locale: locale)
		return collectionRequest(request, recursive: recursive)
	}
	
	func playlistEntries(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, recursive: Bool = false) -> Observable<GMusicCollection<GMusicPlaylistEntry>> {
		let request = GMusicRequest(type: .playlistEntry, maxResults: maxResults, updatedMin: updatedMin, locale: locale)
		return collectionRequest(request, recursive: recursive)
	}
	
	func radioStations(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, recursive: Bool = false) -> Observable<GMusicCollection<GMusicRadioStation>> {
		let request = GMusicRequest(type: .radioStation, maxResults: maxResults, updatedMin: updatedMin, locale: locale)
		return collectionRequest(request, recursive: recursive)
	}
}
