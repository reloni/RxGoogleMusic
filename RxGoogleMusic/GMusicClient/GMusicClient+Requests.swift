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
        let request = GMusicRequest(type: .radioStatioFeed(statioId: stationId), baseUrl: baseUrl, dataRequest: dataRequest, maxResults: maxResults, updatedMin: nil, pageToken: .begin, locale: locale)
        return entityCollection(request: request, recursive: false)
    }
	
	func favorites(updatedMin: Date = Date(timeIntervalSince1970: 0), maxResults: Int = 100, pageToken: GMusicNextPageToken = .begin, recursive: Bool = false) -> Observable<GMusicCollection<GMusicTrack>> {
		let request = GMusicRequest(type: .favorites, baseUrl: baseUrl, dataRequest: dataRequest, maxResults: maxResults, updatedMin: updatedMin, pageToken: pageToken, locale: locale)
		return entityCollection(request: request, recursive: recursive)
	}
	
	func artist(_ id: String, includeAlbums: Bool = false, includeBio: Bool = false, numRelatedArtists: Int = 0, numTopTracks: Int = 0) -> Single<GMusicArtist> {
        let request = GMusicRequest(type: .artist(id: id, numRelatedArtists: numRelatedArtists, numTopTracks: numTopTracks, includeAlbums: includeAlbums, includeBio: includeBio), baseUrl: baseUrl, dataRequest: dataRequest, locale: locale)
		return entityRequest(request)
	}
	
	func album(_ id: String, includeDescription: Bool = false, includeTracks: Bool = false) -> Single<GMusicAlbum> {
		let request = GMusicRequest(type: .album(id: id, includeDescription: includeDescription, includeTracks: includeTracks), baseUrl: baseUrl, dataRequest: dataRequest, locale: locale)
		return entityRequest(request)
	}
    
    func downloadTrack(id trackId: String) -> Single<Data> {
        let request = GMusicRequest(type: .stream(trackId: trackId, quality: .high), baseUrl: baseUrl, dataRequest: dataRequest, maxResults: 0, updatedMin: nil, pageToken: .begin, locale: locale)
        return apiRequest(request)
    }
    
    func downloadTrack(_ track: GMusicTrack) -> Single<Data> {
        return downloadTrack(id: track.nid ?? "")
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
