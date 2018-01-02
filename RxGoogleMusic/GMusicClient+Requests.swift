//
//  GMusicClient+Requests.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

extension GMusicClient {
	public func tracks(token: String, updatedMin: Date, maxResults: Int = 100, recursive: Bool = false) -> Observable<GMusicCollection<GMusicTrack>> {
		let request = GMusicRequest(type: .track, maxResults: maxResults, updatedMin: updatedMin, token: token, locale: locale, tier: tier)
		return loadCollection(request, recursive: recursive)
	}
	
	public func playlists(token: String, updatedMin: Date, maxResults: Int = 100, recursive: Bool = false) -> Observable<GMusicCollection<GMusicPlaylist>> {
		let request = GMusicRequest(type: .playlist, maxResults: maxResults, updatedMin: updatedMin, token: token, locale: locale, tier: tier)
		return loadCollection(request, recursive: recursive)
	}
	
	public func playlistEntries(token: String, updatedMin: Date, maxResults: Int = 100, recursive: Bool = false) -> Observable<GMusicCollection<GMusicPlaylistEntry>> {
		let request = GMusicRequest(type: .playlistEntry, maxResults: maxResults, updatedMin: updatedMin, token: token, locale: locale, tier: tier)
		return loadCollection(request, recursive: recursive)
	}
}
