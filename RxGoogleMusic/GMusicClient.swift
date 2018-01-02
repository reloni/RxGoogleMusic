//
//  GMusicClient.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

final class GMusicClient {
	public let baseUrl: URL
	public let session: URLSession
	public let locale: Locale
	let tier: String
	
	public init(session: URLSession = URLSession.shared,
				locale: Locale = Locale.current,
				tier: String = "aa",
				baseUrl: URL = URL(string: "https://mclients.googleapis.com/sj/v2.5")!) {
		self.session = session
		self.locale = locale
		self.tier = tier
		self.baseUrl = baseUrl
	}
	
	public func tracks(token: String, updatedMin: Date, maxResults: Int = 100, recursive: Bool = false) -> Observable<GMusicCollection<GMusicTrack>> {
		let request = GMusicRequest(type: .track, maxResults: maxResults, updatedMin: updatedMin, token: token, locale: locale, tier: tier)
		
		guard recursive else { return collectionRequest(request) }
		
		return Observable.create { [weak self] observer in
			guard let client = self else { observer.onCompleted(); return Disposables.create() }

			let subscription =
				client.recursiveCollectionRequest(request: request,
										invokeRequest: { [weak self] in self?.collectionRequest($0) ?? .empty() },
										observer: observer)
					.do(onError: { observer.onError($0) })
					.subscribe()
			
			return Disposables.create([subscription])
		}
	}
	
	func recursiveCollectionRequest<T>(request: GMusicRequest,
							 invokeRequest: @escaping  (GMusicRequest) -> Observable<GMusicCollection<T>>,
							 observer: AnyObserver<GMusicCollection<T>>) -> Observable<Void> {
		return invokeRequest(request).flatMap { [weak self] result -> Observable<Void> in
			guard let client = self else { observer.onCompleted(); return .empty() }
			
			observer.onNext(result)
			
			guard let nextPage = result.nextPageToken else { observer.onCompleted(); return .empty() }
			
			print("extracted next page: \(nextPage)")
			return client.recursiveCollectionRequest(request: request.withNew(nextPageToken: nextPage), invokeRequest: invokeRequest, observer: observer)
				.delaySubscription(0.5, scheduler: MainScheduler.instance)
		}
	}
	
	func collectionRequest<T>(_ request: GMusicRequest) -> Observable<GMusicCollection<T>> {
		return dataRequest(request).flatMap { data -> Observable<GMusicCollection<T>> in
			let result = try JSONDecoder().decode(GMusicCollection<T>.self, from: data)
			return .just(result)
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
				
				if !(200...299 ~= (response as? HTTPURLResponse)?.statusCode ?? 0) {
					print("Internal error: \(String(data: data, encoding: .utf8)!)")
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
