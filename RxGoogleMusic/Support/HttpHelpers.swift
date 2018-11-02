//
//  HTTP.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 31/10/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxSwift
import Foundation

private func dataRequest(_ request: URLRequest, in session: URLSession) -> Single<Data> {
    return Single.create { single in
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                single(.error(GMusicError.urlRequestLocalError(error)))
                return
            }
            
            if !(200...299 ~= (response as? HTTPURLResponse)?.statusCode ?? 0) {
                #if DEBUG
                if let data = data, let responseString = String.init(data: data, encoding: .utf8) {
                    print("Response string: \(responseString)")
                }
                #endif
                
                single(.error(GMusicError.urlRequestError(response: response!, data: data)))
                return
            }
            
            guard let data = data else {
                single(.error(GMusicError.emptyDataResponse))
                return
            }
            
            single(.success(data))
        }
        
        #if DEBUG
        print("URL \(task.originalRequest!.url!.absoluteString)")
        #endif
        
        task.resume()
        
        return Disposables.create { task.cancel() }
    }
}

func jsonRequest(from dataRequest: Single<Data>) -> Single<JSON> {
    return dataRequest
        .flatMap { data -> Single<JSON> in
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON else {
                    return .error(GMusicError.unknownJsonStructure)
                }
                return .just(json)
            } catch let error {
                return .error(GMusicError.jsonParseError(error))
            }
    }
}

func dataRequest(for session: URLSession) -> (URLRequest) -> Single<Data> {
    return session
        |> (dataRequest |> curry |> flip)
}

func jsonRequest(for session: URLSession) -> (URLRequest) -> Single<JSON> {
    let request = (session |> dataRequest) >>> jsonRequest
    
    return { return $0 |> request }
    
}
