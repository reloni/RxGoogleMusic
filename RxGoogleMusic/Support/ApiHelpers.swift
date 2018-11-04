//
//  ApiHelpers.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 04/11/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

func createApiRequest(for request: GMusicRequest, baseUrl: URL, dataRequest: @escaping (URLRequest) -> Single<Data>) -> (GMusicToken) -> Single<Data> {
    return { token in
        return token
            |> apiRequest(baseUrl, request) >>> dataRequest
    }
}
