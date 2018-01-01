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
	let liveToken = "ya29.GosBNQWhG_ntTf0U9jM9NUEOOSPFx14sd43XeDeqFmxVfQfcdQOzBDKsxAGIXGm9e1sNWnVonFs_g7niPoOZ8sDDcj-_A8Xq5foB8ZV1DXwPo9NNW3yd6nwGPqicYRlbVlIUm51n7hxaA32giAxiV-WGQ63XOn8TX2HiPzNKMT6bB7r8ml5h8BdGqqvGww"
	
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
				resultExpectation.fulfill()
			})
			.do(onError: { print($0) })
			.subscribe()
		
		_ = XCTWaiter.wait(for: [resultExpectation], timeout: 1)
	}
}
