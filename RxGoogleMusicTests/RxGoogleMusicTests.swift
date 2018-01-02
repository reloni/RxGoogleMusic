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
	let liveToken = "ya29.GooBNgX8s0tB9lPlzzAuzOvyDg-Jp7qkNTlSOsAUfv1H4VMWiy2iB4vq306yamYRuvxwsanqhJQZkAyVC89R-RjTBVu4vCrIN2UDTWKw8OU_McqTj_IVGBnFA-abjPo7zrpHSfHpa0sr5se20bZ-0vPy_u8qODzI9CrnwIrPO2Zf2yTVu3-YUhiqVZ9o"
	
//	func testLoadJson() {
//		let client = GMusicClient()
//		
//		let resultExpectation = expectation(description: "Should return json data")
//		
//		_ = client.jsonRequest(GMusicRequest(type: .track, maxResults: 5, updatedMin: Date(), token: liveToken))
//			.do(onNext: { result in
//				print(result)
//				resultExpectation.fulfill()
//			})
//			.do(onError: { print($0) })
//			.subscribe()
//		
//		_ = XCTWaiter.wait(for: [resultExpectation], timeout: 1)
//	}
	
	func testLoadTracks() {
		let client = GMusicClient()
		
		let resultExpectation = expectation(description: "Should return json data")
		
		_ = client.tracks(token: liveToken, updatedMin: Date(microsecondsSince1970: 1514132217511863), maxResults: 100)
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
		let client = GMusicClient()
		
		let resultExpectation = expectation(description: "Should return json data")
		
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
