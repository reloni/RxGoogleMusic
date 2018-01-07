//
//  RxGoogleMusicTests.swift
//  RxGoogleMusicTests
//
//  Created by Anton Efimenko on 26.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import XCTest
import RxSwift
@testable import RxGoogleMusic

class RxGoogleMusicTests: XCTestCase {
	let liveToken = "ya29.GooBOwW8MCJc76mBF_q9BdMxB0lOyyXi9ldxrMagXU3plSlYYDT9dSA58RE9LDs6uVcp-f-WulWri_L36bNtZiUL4peVRcAnpZZtvHoqflhllEWekdsSCtbK_-T-WaWe-6QxI9fJPhlcJMWd6we1lZ7X_R49au-rNY2CK_sU-XLJiYOTvOz5yNNbC1ii"
	
	let token = GMusicToken(accessToken: "", expiresIn: nil, refreshToken: nil)
	let apiToken = GMusicToken(accessToken: "", expiresIn: nil, refreshToken: nil)
	
	var client: GMusicClient!
	
	override func setUp() {
		client = GMusicClient(token: token)
		client.apiToken = apiToken
	}
	
	func testLoadTracks() {
		let resultExpectation = expectation(description: "Should return data")
		
		_ = client.tracks(token: liveToken, updatedMin: Date(microsecondsSince1970: 1514132217511863), maxResults: 2)
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
		
		_ = client.tracks(token: liveToken, updatedMin: Date(microsecondsSince1970: 0), maxResults: 250, recursive: true)
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
		
		_ = client.playlists(token: liveToken, updatedMin: Date(microsecondsSince1970: 1514132217511863), maxResults: 2)
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
		
		_ = client.playlists(token: liveToken, updatedMin: Date(microsecondsSince1970: 0), maxResults: 1, recursive: true)
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
		
		_ = client.playlistEntries(token: liveToken, updatedMin: Date(microsecondsSince1970: 0), maxResults: 100, recursive: true)
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
	
	func testEscapeNextPageToken() {
		let token = "KngKS/fiRWcN/////zzrdXkSE0wf/wD+//6Ynpaexc/Pz8/Pz5rGx5nKyM2dms/Fy8zFy8zei43FzsrPz8jKx8/Oyc7Ix8fIys/Oz8v//hBkIRzbqFg2k+ObOQAAAADymLodSANQAFoLCc72Cz/OJRQ6EAJg0fbfswYyDQoLCgAo+Nns25vUyAI="
		var chars = CharacterSet.urlHostAllowed
		chars.remove("=")
		chars.remove("+")
		let result = token.addingPercentEncoding(withAllowedCharacters: chars)
		let escaped = "KngKS%2FfiRWcN%2F%2F%2F%2F%2FzzrdXkSE0wf%2FwD%2B%2F%2F6Ynpaexc%2FPz8%2FPz5rGx5nKyM2dms%2FFy8zFy8zei43FzsrPz8jKx8%2FOyc7Ix8fIys%2FOz8v%2F%2FhBkIRzbqFg2k%2BObOQAAAADymLodSANQAFoLCc72Cz%2FOJRQ6EAJg0fbfswYyDQoLCgAo%2BNns25vUyAI%3D"
		XCTAssertEqual(result, escaped)
	}
}
