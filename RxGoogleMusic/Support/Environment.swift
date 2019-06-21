//
//  Environment.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 21/06/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift

struct Environment {
    static let current = Environment()
    
    var httpClient = GMusicHttpClient.default
}

extension Environment {
    struct GMusicHttpClient {
        static let `default` = GMusicHttpClient()
        
        var getAuthenticationUrl = gMusicAuthenticationUrl(for:deviceId:)
        var exchangeCodeForToken = exchangeOAuthCodeForToken(code:jsonRequest:)
        var refreshAndIssueTokens = refreshAndIssueTokens(gMusicToken:deviceId:force:jsonRequest:)
        var createRequest = createUrlRequest(for:)
        var dataRequest = dataRequest(_:in:)
        
        func dataRequest(for session: URLSession) -> (URLRequest) -> Single<Data> {
            return session |> (dataRequest |> curry |> flip)
        }
        
        func jsonRequest(for session: URLSession) -> (URLRequest) -> Single<JSON> {
            return { self.dataRequest($0, session).map(dataToJson) }
        }
        
        func jsonRequest(from dataRequest: Single<Data>) -> Single<JSON> {
            return dataRequest.map(dataToJson)
        }
    }
}
