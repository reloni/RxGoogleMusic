//
//  Extensions.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

extension CharacterSet {
	static let nextPageTokenAllowed: CharacterSet = {
		var chars = CharacterSet.urlHostAllowed
		chars.remove("=")
		chars.remove("+")
		return chars
	}()
}

extension URL {
	init?(baseUrl: String, parameters: [String: String]) {
		var components = URLComponents(string: baseUrl)
		components?.queryItems = parameters.map {
			return URLQueryItem(name: $0.key, value: $0.value)
		}
		
		guard let created = components?.url else { return nil }
		
		self = created
	}
}

extension URLRequest {
    init(url: URL, method: HttpMethod = .get, body: Data? = nil, headers: [String: String]) {
        self = URLRequest(url: url)
        self.httpMethod = method.rawValue
        self.httpBody = body
        headers.forEach { addValue($0.1, forHTTPHeaderField: $0.0) }
    }

	static func issueMusicApiTokenRequest(token: GMusicToken) -> URLRequest {
		var request = URLRequest(url: GMusicConstants.issueTokenUrl)
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
		request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "POST"
		let body =
				"""
				client_id=\(GMusicConstants.clientIdLong)&
				app_id=\(GMusicConstants.packageName)&
				device_id=\(GMusicConstants.deviceId)&
				hl=\(Locale.current.identifier)&
				response_type=token&
				scope=\(Scope.skyjam.rawValue) \(Scope.supportcontent.rawValue)
				"""
				.replacingOccurrences(of: "\n", with: "")
		request.httpBody = body.data(using: .utf8)
		return request
	}
	
	static func loginPageRequest(_ url: URL) -> URLRequest {
		var request = URLRequest(url: url)
		request.addValue(GMusicConstants.deviceId, forHTTPHeaderField: "X-IOS-Device-ID")
		request.addValue("embedded", forHTTPHeaderField: "X-Browser-View")
		return request
	}
}

extension Date {
	var microsecondsSince1970: UInt64 {
		return UInt64(timeIntervalSince1970 * 1_000_000)
	}
	
	init(microsecondsSince1970: UInt64) {
		self.init(timeIntervalSince1970: Double(microsecondsSince1970) / 1_000_000)
	}
}

extension KeyedDecodingContainer {
	public func decode<T: Decodable>(_ key: Key, as type: T.Type = T.self) throws -> T {
		return try self.decode(T.self, forKey: key)
	}
	
	public func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T? {
		return try decodeIfPresent(T.self, forKey: key)
	}
}
