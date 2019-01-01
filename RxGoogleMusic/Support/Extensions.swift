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
    
    func appendingParameter(key: String, rawValue: String?) -> URL? {
        guard let value = rawValue else { return self }
        let delimeter = self.pathComponents.count == 0 ? "?" : "&"
        return URL(string: "\(absoluteString)\(delimeter)\(key)=\(value)")
    }
}

extension URLRequest {
    init(url: URL, method: HttpMethod = .get, body: Data? = nil, headers: [String: String]) {
        self = URLRequest(url: url)
        self.httpMethod = method.rawValue
        self.httpBody = body
        headers.forEach { addValue($0.1, forHTTPHeaderField: $0.0) }
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
