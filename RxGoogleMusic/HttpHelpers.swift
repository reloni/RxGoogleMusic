//
//  HTTP.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 31/10/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxSwift
import Foundation

func dataRequest(_ request: URLRequest, in session: URLSession) -> Single<Data> {
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

func jsonRequest(_ request: Single<Data>) -> Single<JSON> {
    return request
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


let sessionDataRequest = flip(curry(dataRequest))

let sessionJsonRequest = { (session: URLSession) -> (URLRequest) -> Single<JSON> in
    return { request in
        return request
            |> (session |> sessionDataRequest)
            |> jsonRequest
    }
}
