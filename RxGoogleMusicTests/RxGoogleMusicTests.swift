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
	let liveToken = "ya29.GosBNQULmCFqB1JU9vmQVSkPiz4Kigln8dM3pAcdFDceJ3auGdCo2JjYbypRQ_FREXwY2KnmcWQcjglHucNpTJcJITu0EtZDlpOSObRqxDmdMa0AKLlFhw8a-Nf6w4KUho5-Z6EupA2_EkvrfEoFjIY39_KIdXaumzQvypZCiFf6Rp2_Pe9oSmHjqRUs_w"
	
	func testLoadTracks() {
		let client = GMusicClient()
		
		let resultExpectation = expectation(description: "Should return json data")
		
		_ = client.jsonRequest(GMusicRequest(type: .track, maxResults: 5, updatedMin: 0, token: liveToken, locale: "ru-RU", tier: "aa"))
			.do(onNext: { result in
				print(result)
				resultExpectation.fulfill()
			})
			.do(onError: { print($0) })
			.subscribe()
		
		_ = XCTWaiter.wait(for: [resultExpectation], timeout: 1)
	}
}
