//
//  GMusicClientTests.swift
//  RxGoogleMusicTests
//
//  Created by Anton Efimenko on 10/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import XCTest
@testable import RxGoogleMusic

class GMusicClientTests: XCTestCase {
    let client = GMusicClient(token: GMusicToken(accessToken: "",
                                                 expiresIn: 99999999,
                                                 refreshToken: ""))
    
    func testLoadTracks() {
        let resultExpectation = expectation(description: "Should return data")
        
        _ = client.tracks(updatedMin: Date(microsecondsSince1970: 1514132217511863), maxResults: 2)
            .do(onNext: { result in
                print(result)
                XCTAssertEqual(2, result.items.count)
                resultExpectation.fulfill()
            })
            .do(onError: { print($0) })
            .subscribe()
        
        let result = XCTWaiter.wait(for: [resultExpectation], timeout: 1)
        XCTAssertEqual(result, .completed)
    }
    
    func testLoadTracksRecursive() {
        let resultExpectation = expectation(description: "Should return data")
        
        _ = client.tracks(updatedMin: Date(microsecondsSince1970: 0), maxResults: 250, recursive: true)
            .do(onNext: { result in
                print("Tracks loaded: \(result.items.count)")
                print("First track: \(result.items.first?.title ?? "none")")
            })
            .do(onError: { print($0) })
            .do(onCompleted: { resultExpectation.fulfill() })
            .subscribe()
        
        let result = XCTWaiter.wait(for: [resultExpectation], timeout: 20)
        XCTAssertEqual(result, .completed)
    }
    
    func testLoadPlaylists() {
        let resultExpectation = expectation(description: "Should return data")
        
        _ = client.playlists(updatedMin: Date(microsecondsSince1970: 1514132217511863), maxResults: 2)
            .do(onNext: { result in
                print(result)
                XCTAssertEqual(1, result.items.count)
                resultExpectation.fulfill()
            })
            .do(onError: { print($0) })
            .subscribe()
        
        let result = XCTWaiter.wait(for: [resultExpectation], timeout: 1)
        XCTAssertEqual(result, .completed)
    }
    
    func testLoadPlaylistsRecursive() {
        let resultExpectation = expectation(description: "Should return data")
        
        _ = client.playlists(updatedMin: Date(microsecondsSince1970: 0), maxResults: 1, recursive: true)
            .do(onNext: { result in
                print("Playlists loaded: \(result.items.count)")
                print("First playlist: \(result.items.first?.name ?? "none")")
            })
            .do(onError: { print($0) })
            .do(onCompleted: { resultExpectation.fulfill() })
            .subscribe()
        
        let result = XCTWaiter.wait(for: [resultExpectation], timeout: 20)
        XCTAssertEqual(result, .completed)
    }
    
    func testLoadPlaylistEntriesRecursive() {
        let resultExpectation = expectation(description: "Should return data")
        
        _ = client.playlistEntries(updatedMin: Date(microsecondsSince1970: 0), maxResults: 100, recursive: true)
            .do(onNext: { result in
                print("Entries loaded: \(result.items.count)")
                print("First entry track title: \(result.items.first?.track?.title ?? "none")")
            })
            .do(onError: { print($0) })
            .do(onCompleted: { resultExpectation.fulfill() })
            .subscribe()
        
        let result = XCTWaiter.wait(for: [resultExpectation], timeout: 20)
        XCTAssertEqual(result, .completed)
    }
    
    func testFetchArtist() {
        let resultExpectation = expectation(description: "Should return data")
        
        _ = client.artist("Ad3ihvu6n5vlut7aotw4h5nxnii", includeAlbums: true, includeBio: true, numRelatedArtists: 10, numTopTracks: 10)
            .do(onSuccess: { result in
                print("artist name: \(result.name)")
                print("first album: \(result.albums.first?.name ?? "empty")")
                resultExpectation.fulfill() })
            .do(onError: { print($0) })
            .subscribe()
        
        let result = XCTWaiter.wait(for: [resultExpectation], timeout: 2)
        XCTAssertEqual(result, .completed)
    }
    
    func testFetchAlbum() {
        let resultExpectation = expectation(description: "Should return data")
        
        _ = client.album("Bl2h34y6vwttexbvcznuidhwpyu", includeDescription: true, includeTracks: true)
            .do(onSuccess: { result in
                print("album name: \(result.name)")
                print("first track: \(result.tracks?.first?.title ?? "empty")")
                resultExpectation.fulfill()
            })
            .do(onError: { print($0) })
            .subscribe()
        
        let result = XCTWaiter.wait(for: [resultExpectation], timeout: 2)
        XCTAssertEqual(result, .completed)
    }

}
