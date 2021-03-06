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
    func gMusicRequest(_ type: GMusicRequestType, maxResults: Int = 25, updatedMin: Date? = nil, pageToken: GMusicNextPageToken = .begin) -> GMusicRequest {
        return GMusicRequest(type: type,
                             baseUrl: baseUrl,
                             deviceId: deviceId,
                             dataRequest: dataRequest,
                             maxResults: maxResults,
                             updatedMin: updatedMin,
                             pageToken: pageToken,
                             locale: locale)
    }
    
	func entityCollection<Element: GMusicEntity>(updatedMin: Date,
												 maxResults: Int,
												 pageToken: GMusicNextPageToken,
												 recursive: Bool) -> Observable<GMusicCollection<Element>> {
        let request = GMusicRequest(type: Element.collectionRequestPath, baseUrl: baseUrl, deviceId: deviceId, dataRequest: dataRequest, maxResults: maxResults, updatedMin: updatedMin, pageToken: pageToken, locale: locale)
		return entityCollection(request: request, recursive: recursive)
	}
	
	func entityCollection<Element: GMusicEntity>(request: GMusicRequest, recursive: Bool) -> Observable<GMusicCollection<Element>> {
		return collectionRequest(request, recursive: recursive)
	}
	
	private func collectionRequest<T>(_ request: GMusicRequest, recursive: Bool) -> Observable<GMusicCollection<T>> {
		if case GMusicNextPageToken.end = request.pageToken { return .empty() }
        
		guard recursive else { return apiRequest(request).map(decode).asObservable() }
        
		return Observable.create { [weak self] observer in
			guard let client = self else { observer.onError(GMusicError.clientDisposed); return Disposables.create() }
			
			let subscription =
				client.collectionRequest(request: request,
										 invokeRequest: { [weak self] in self?.apiRequest($0).map(decode) ?? Single.error(GMusicError.clientDisposed) },
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
			
			return client.collectionRequest(request: request.replaced(nextPageToken: result.nextPageToken), invokeRequest: invokeRequest, observer: observer)
		}
	}
	
	func apiRequest(_ request: GMusicRequest) -> Single<GMusicRawResponse> {
        return issueApiToken(force: false)
            .flatMap(request.dataRequest)
	}
    
    func issueApiToken(force: Bool) -> Single<GMusicToken> {
        guard apiToken?.expiresAt ?? Date(timeIntervalSince1970: 0) < Date() || force else {
            // if api token existed and not expired, return it
            return .just(apiToken!)
        }
        
        let saveTokens = { [weak self] (gMusicToken: GMusicToken, apiToken: GMusicToken) -> Single<GMusicToken> in
            self?.apiToken = apiToken
            self?.token = gMusicToken
            return apiToken |> Single.just
        }
        
        return Current.httpClient
            .refreshAndIssueTokens(token, deviceId, force, dataRequest >>> singleMap { $0.data } >>> Current.httpClient.jsonRequest)
            .flatMap(saveTokens)
    }
}
