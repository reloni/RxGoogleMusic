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
	func entityCollection<Element: GMusicEntity>(updatedMin: Date,
												 maxResults: Int,
												 pageToken: GMusicNextPageToken,
												 recursive: Bool) -> Observable<GMusicCollection<Element>> {
        let request = GMusicRequest(type: Element.collectionRequestPath, baseUrl: baseUrl, dataRequest: dataRequest, maxResults: maxResults, updatedMin: updatedMin, pageToken: pageToken, locale: locale)
		return entityCollection(request: request, recursive: recursive)
	}
	
	func entityCollection<Element: GMusicEntity>(request: GMusicRequest, recursive: Bool) -> Observable<GMusicCollection<Element>> {
		return collectionRequest(request, recursive: recursive)
	}
	
	private func collectionRequest<T>(_ request: GMusicRequest, recursive: Bool) -> Observable<GMusicCollection<T>> {
		if case GMusicNextPageToken.end = request.pageToken {
			return .empty()
		}
		guard recursive else { return collectionRequest(request).asObservable() }
		return Observable.create { [weak self] observer in
			guard let client = self else { observer.onError(GMusicError.clientDisposed); return Disposables.create() }
			
			let subscription =
				client.collectionRequest(request: request,
										 invokeRequest: { [weak self] in self?.collectionRequest($0) ?? Single.error(GMusicError.clientDisposed) },
										 observer: observer)
					.do(onError: { observer.onError($0) })
					.subscribe()
			
			return Disposables.create([subscription])
		}
	}
	
	private func collectionRequest<T>(request: GMusicRequest,
							  invokeRequest: @escaping  (GMusicRequest) -> Single<GMusicCollection<T>>,
							  observer: AnyObserver<GMusicCollection<T>>) -> Observable<Void> {
		return invokeRequest(request).asObservable().flatMap { [weak self] result -> Observable<Void> in
			guard let client = self else { observer.onCompleted(); return .empty() }
			
			observer.onNext(result)
			
			guard case GMusicNextPageToken.token = result.nextPageToken else { observer.onCompleted(); return .empty() }
			
			return client.collectionRequest(request: request.withNew(nextPageToken: result.nextPageToken), invokeRequest: invokeRequest, observer: observer)
		}
	}
	
	private func collectionRequest<T>(_ request: GMusicRequest) -> Single<GMusicCollection<T>> {
		return apiRequest(request).flatMap { data -> Single<GMusicCollection<T>> in
			let result = try JSONDecoder().decode(GMusicCollection<T>.self, from: data)
			return .just(result)
		}
	}
	
	func entityRequest<T: Decodable>(_ request: GMusicRequest) -> Single<T> {
		return apiRequest(request).flatMap { data -> Single<T> in
			let result = try JSONDecoder().decode(T.self, from: data)
			return .just(result)
		}
	}
	
	private func apiRequest(_ request: GMusicRequest) -> Single<Data> {
        return issueApiToken(force: false)
            .flatMap(request.dataRequest)
	}
    
    private func issueApiToken(force: Bool) -> Single<GMusicToken> {
        guard apiToken?.expiresAt ?? Date(timeIntervalSince1970: 0) < Date() || force else {
            // if api token existed and not expired, return it
            return .just(apiToken!)
        }
        
        let saveTokens = { [weak self] (gMusicToken: GMusicToken, apiToken: GMusicToken) -> Single<GMusicToken> in
            self?.apiToken = apiToken
            self?.token = gMusicToken
            return apiToken |> Single.just
        }
        
        return refreshAndIssueTokens(gMusicToken: token, force: force, jsonRequest: dataRequest >>> jsonRequest)
            .flatMap(saveTokens)
    }
}
