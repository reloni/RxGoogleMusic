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
	let liveToken = "ya29.GooBNgURzsEUaLtX3DnKSnjlT7E6yfB1vn4uZr2E_0KZutftysL9MSpaGvDibI4QolffcaBm6pV82slxxcYQQMYd98vl03-6SJtLkITabPtm_W10CWq7W6OGlXuI6HxeTB3iGFeo5dDdGdM59sNbpvSp6_EO59etncgg22AVFlJBCeZPNo8a4ApZsjqR"
	
	func testLoadJson() {
		let client = GMusicClient()
		
		let resultExpectation = expectation(description: "Should return json data")
		
		_ = client.jsonRequest(GMusicRequest(type: .track, maxResults: 5, updatedMin: Date(), token: liveToken))
			.do(onNext: { result in
				print(result)
				resultExpectation.fulfill()
			})
			.do(onError: { print($0) })
			.subscribe()
		
		_ = XCTWaiter.wait(for: [resultExpectation], timeout: 1)
	}
	
	func testLoadTracks() {
		let client = GMusicClient()
		
		let resultExpectation = expectation(description: "Should return json data")
		
		_ = client.tracks(token: liveToken, maxResults: 2, updatedMin: Date(microsecondsSince1970: 1514132217511863))
			.do(onNext: { result in
				print(result)
				XCTAssertEqual(2, result.items.count)
				resultExpectation.fulfill()
			})
			.do(onError: { print($0) })
			.subscribe()
		
		_ = XCTWaiter.wait(for: [resultExpectation], timeout: 1)
	}
}
