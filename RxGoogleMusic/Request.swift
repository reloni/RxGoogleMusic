//
//  Request.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

final class GMusicClient {
	let baseUrl: URL
	let session: URLSession
	
	public init(session: URLSession = URLSession.shared, baseUrl: URL = URL(string: "https://mclients.googleapis.com/sj/v2.5")!) {
		self.session = session
		self.baseUrl = baseUrl
	}
	
	func jsonRequest(_ request: GMusicRequest) -> Observable<JSON> {
		return dataRequest(request).flatMap { data -> Observable<JSON> in
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON
				return .just(json ?? [:])
			} catch let error {
				return .error(error)
			}
		}
	}
	
	func dataRequest(_ request: GMusicRequest) -> Observable<Data> {
		return Observable.create { [weak self] observer in
			guard let client = self else { observer.onCompleted(); return Disposables.create() }
			let task = client.session.dataTask(with: request.createGMusicRequest(for: client.baseUrl)) { data, response, error in
				if let error = error {
					observer.onError(error)
					return
				}
				
				guard let data = data else { observer.onCompleted(); return }
				
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
