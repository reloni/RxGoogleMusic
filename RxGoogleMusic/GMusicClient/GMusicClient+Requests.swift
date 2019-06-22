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
    
    func radioStationFeed(for station: GMusicRadioStation, maxResults: Int = 100) -> Observable<GMusicCollection<GMusicRadioStation>> {
        guard let stationId = station.id?.uuidString.lowercased() else { return .empty() }
        return entityCollection(request: gMusicRequest(.radioStatioFeed(statioId: stationId), maxResults: maxResults),
                                recursive: false)
    }
	
	func favorites(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, pageToken: GMusicNextPageToken = .begin, recursive: Bool = false) -> Observable<GMusicCollection<GMusicTrack>> {
        return entityCollection(request: gMusicRequest(.favorites, maxResults: maxResults, updatedMin: updatedMin, pageToken: pageToken),
                                recursive: recursive)
	}
	
	func artist(_ id: String, includeAlbums: Bool = false, includeBio: Bool = false, numRelatedArtists: Int = 0, numTopTracks: Int = 0) -> Single<GMusicArtist> {
		return gMusicRequest(.artist(id: id, numRelatedArtists: numRelatedArtists, numTopTracks: numTopTracks, includeAlbums: includeAlbums, includeBio: includeBio))
            |> entityRequest
	}
	
	func album(_ id: String, includeDescription: Bool = false, includeTracks: Bool = false) -> Single<GMusicAlbum> {
		return gMusicRequest(.album(id: id, includeDescription: includeDescription, includeTracks: includeTracks))
            |> entityRequest
	}
    
    func downloadTrack(id trackId: String) -> Single<Data> {
        return gMusicRequest(.stream(trackId: trackId, quality: .high))
            |> apiRequest
    }
    
    func downloadTrack(_ track: GMusicTrack) -> Single<Data> {
        return downloadTrack(id: track.identifier ?? "")
    }
    
    func downloadArt(_ artRef: GMusicRef) -> Single<Data> {
        return artRef.url
            |> urlRequest
            >>> dataRequest
    }
    
    func downloadAlbumArt(_ track: GMusicTrack) -> Single<Data?> {
        return track.albumArtRef?.first.flatMap { downloadArt($0).map(Optional.init) } ?? Single.just(nil)
    }
}
