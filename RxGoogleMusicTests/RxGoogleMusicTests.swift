//
//  RxGoogleMusicTests.swift
//  RxGoogleMusicTests
//
//  Created by Anton Efimenko on 26.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import XCTest
@testable import RxGoogleMusic

class RxGoogleMusicTests: XCTestCase {
	func testEscapeNextPageToken() {
		let token = "KngKS/fiRWcN/////zzrdXkSE0wf/wD+//6Ynpaexc/Pz8/Pz5rGx5nKyM2dms/Fy8zFy8zei43FzsrPz8jKx8/Oyc7Ix8fIys/Oz8v//hBkIRzbqFg2k+ObOQAAAADymLodSANQAFoLCc72Cz/OJRQ6EAJg0fbfswYyDQoLCgAo+Nns25vUyAI="
		let result = token.addingPercentEncoding(withAllowedCharacters: CharacterSet.nextPageTokenAllowed)
		let escaped = "KngKS%2FfiRWcN%2F%2F%2F%2F%2FzzrdXkSE0wf%2FwD%2B%2F%2F6Ynpaexc%2FPz8%2FPz5rGx5nKyM2dms%2FFy8zFy8zei43FzsrPz8jKx8%2FOyc7Ix8fIys%2FOz8v%2F%2FhBkIRzbqFg2k%2BObOQAAAADymLodSANQAFoLCc72Cz%2FOJRQ6EAJg0fbfswYyDQoLCgAo%2BNns25vUyAI%3D"
		XCTAssertEqual(result, escaped)
	}
    
    func testHardwareType() {
        #if os(iOS)
        XCTAssertEqual(.iOS, Current.hardware)
        #elseif os(macOS)
        XCTAssertEqual(.macOS, Current.hardware)
        #else
        fatalError()
        #endif
    }
    
    func testSignString() {
        let (sig, slt) = Hmac.sign(string: "Txb2nm5efzvwuhflshdgx46vjla", salt: 1545310567294)
        XCTAssertEqual(sig, "EXvffRIs4-r2WyQ4V3AwSy_Tcfo=")
        XCTAssertEqual(slt, "1545310567294")
        
        let salt = Hmac.currentSalt
        let current = Int(Date().timeIntervalSince1970 * 1000)
        XCTAssertEqual(salt, current)
    }
}
