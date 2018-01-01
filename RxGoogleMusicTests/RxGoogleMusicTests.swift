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
	let liveToken = "ya29.GosBNQUp17lnsLdM90lZ7YQK9g0raGGhpOyQFqmmDzHTsXILzElDMKn8k69Funx_ZhYIryPAg0Awh05XNHpawculaO0OqkKmuI5hx1ALrs3Alp8akI8lJD3BBQWQ8yNvLMsvXNvmzBP5yt-2kO9ErqzEnr1ZaIBesLxe61oSuG9dWsB48GrYzJw9owdFIA"
	
	func testLoadTracks() {
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
}
