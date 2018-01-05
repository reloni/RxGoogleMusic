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

extension URLSession {
	func invoke(request: URLRequest) -> Observable<Data> {
		return Observable.create { [weak self] observer in
			guard let session = self else { observer.onCompleted(); return Disposables.create() }
			let task = session.dataTask(with: request) { data, response, error in
				if let error = error {
					observer.onError(error)
					return
				}
				
				guard let data = data else { observer.onCompleted(); return }
				
				if !(200...299 ~= (response as? HTTPURLResponse)?.statusCode ?? 0) {
					print("Internal error: \(String(data: data, encoding: .utf8)!)")
					fatalError("Now simply trap :(")
				}
				
				observer.onNext(data)
				observer.onCompleted()
			}
			
			#if DEBUG
				print("URL \(task.originalRequest!.url!.absoluteString)")
			#endif
			
			task.resume()
			
			return Disposables.create {
				task.cancel()
				observer.onCompleted()
			}
		}
	}
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
	
	static func authAdviceRequest() -> URLRequest {
		let json =
		"""
		{
		"report_user_id": "true",
		"system_version": "\(GMusicConstants.systemVersion)",
		"app_version": "1.0",
		"user_id": [],
		"request_trigger": "ADD_ACCOUNT",
		"lib_ver": "3.2",
		"package_name": "\(GMusicConstants.packageName)",
		"supported_service": ["uca"],
		"redirect_uri": "\(GMusicConstants.redirectUri)",
		"device_name": "\(GMusicConstants.deviceModel)",
		"fast_setup": "true",
		"mediator_client_id": "\(GMusicConstants.clientId)",
		"device_id": "\(GMusicConstants.deviceId)",
		"hl": "\(Locale.current.identifier)",
		"client_id": "\(GMusicConstants.clientIdLong)"
		}
		"""
		
		var request = URLRequest(url: GMusicConstants.authAdviceUrl)
		request.addValue("application/json", forHTTPHeaderField: "content-type")
		request.httpMethod = "POST"
		request.httpBody = json.data(using: .utf8)
		
		return request
	}
	
	static func codeForTokenExchangeRequest(_ code: String) -> URLRequest {
		var request = URLRequest(url: GMusicConstants.tokenUrl)
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
		request.httpMethod = "POST"
		let body =
				"""
				grant_type=\(GrantType.authorizationCode.rawValue)&
				code=\(code)&
				client_id=\(GMusicConstants.clientId)&
				client_secret=\(GMusicConstants.clientSecret)&
				scope=\(Scope.oauthLogin.rawValue)
				"""
				.replacingOccurrences(of: "\n", with: "")
		request.httpBody = body.data(using: .utf8)
		return request
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
}

extension Date {
	var microsecondsSince1970: UInt64 {
		return UInt64(timeIntervalSince1970 * 1_000_000)
	}
	
	init(microsecondsSince1970: UInt64) {
		self.init(timeIntervalSince1970: Double(microsecondsSince1970) / 1_000_000)
	}
}
