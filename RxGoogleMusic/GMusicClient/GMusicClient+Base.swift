//
//  GMusicClient+Base.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 02.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

extension GMusicClient {	
	func collectionRequest<T>(_ request: GMusicRequest, recursive: Bool) -> Observable<GMusicCollection<T>> {
		guard recursive else { return collectionRequest(request) }
		return Observable.create { [weak self] observer in
			guard let client = self else { observer.onCompleted(); return Disposables.create() }
			
			let subscription =
				client.collectionRequest(request: request,
										 invokeRequest: { [weak self] in self?.collectionRequest($0) ?? .empty() },
										 observer: observer)
					.do(onError: { observer.onError($0) })
					.subscribe()
			
			return Disposables.create([subscription])
		}
	}
	
	func collectionRequest<T>(request: GMusicRequest,
							  invokeRequest: @escaping  (GMusicRequest) -> Observable<GMusicCollection<T>>,
							  observer: AnyObserver<GMusicCollection<T>>) -> Observable<Void> {
		return invokeRequest(request).flatMap { [weak self] result -> Observable<Void> in
			guard let client = self else { observer.onCompleted(); return .empty() }
			
			observer.onNext(result)
			
			guard let nextPage = result.nextPageToken else { observer.onCompleted(); return .empty() }
			
			return client.collectionRequest(request: request.withNew(nextPageToken: nextPage), invokeRequest: invokeRequest, observer: observer)
		}
	}
	
	func collectionRequest<T>(_ request: GMusicRequest) -> Observable<GMusicCollection<T>> {
		return session.dataRequest(request.createGMusicRequest(for: baseUrl)).flatMap { data -> Observable<GMusicCollection<T>> in
			let result = try JSONDecoder().decode(GMusicCollection<T>.self, from: data)
			return .just(result)
		}
	}
}
