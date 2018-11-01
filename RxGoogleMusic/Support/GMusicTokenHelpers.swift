//
//  GMusicTokenHelpers.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01/11/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

func gMusicAuthenticationUrl(_ request: URLRequest, in session: URLSession) -> Single<URL> {
    return request
        |> (session |> jsonRequest)
        |> gMusicAuthenticationUrl
}

func gMusicAuthenticationUrl(for session: URLSession) -> Single<URL> {
    return gMusicAuthenticationUrl(URLRequest.authAdviceRequest(), in: session)
}

func gMusicAuthenticationUrl(from request: Single<JSON>) -> Single<URL> {
    return request.flatMap { json -> Single<URL> in
        guard let uri = URL(string: json["uri"] as? String ?? "") else {
            return .error(GMusicError.unableToRetrieveAuthenticationUri(json: json))
        }
        return .just(uri)
    }
}
