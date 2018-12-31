//
//  HTTP.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 31/10/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import RxSwift
import Foundation

func urlRequest(from url: URL) -> URLRequest {
    return URLRequest(url: url)
}

func dictionaryPair<T>(key: String, value: T?) -> (String, String)? {
    guard let v = value else { return nil }
    return (key, String(describing: v))
}

func setJson(key: String, value: Any?) -> (JSON) -> JSON {
    return { json in
        var copy = json
        copy[key] = value
        return copy
    }
}

func jsonToData(_ json: JSON) -> Data? {
    return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
}

// MARK: Request setters
func setBody(_ body: Data?) -> (URLRequest) -> URLRequest {
    return { request in
        return request |> (\.httpBody .~ body)
    }
}

func setMethod(_ method: HttpMethod) -> (URLRequest) -> URLRequest {
    return { request in
        return request |> (\.httpMethod .~ (method.rawValue as String?))
    }
}

func setHeader(field: String, value: String?) -> (URLRequest) -> URLRequest {
    return { request in
        return request |> ((\.[field] .~ value) |> property(\.allHTTPHeaderFields) <<< map)
    }
}

func setAuthorization(_ token: String) -> (URLRequest) -> URLRequest {
    return { request in
        return request |> ((\.["Authorization"] .~ "Bearer \(token)") |> property(\.allHTTPHeaderFields) <<< map)
    }
}

let defaultHeaders: (URLRequest) -> URLRequest = (\.allHTTPHeaderFields .~ ["X-Device-ID":"ios:\(GMusicConstants.deviceId)"])
let postHeader: (URLRequest) -> URLRequest = defaultHeaders
    <> setMethod(.post)
let postJson: (URLRequest) -> URLRequest = postHeader
    <> setHeader(field: "content-type", value: "application/json")
let postUrlEncoded: (URLRequest) -> URLRequest = postHeader
    <> setHeader(field: "content-type", value: "application/x-www-form-urlencoded")

// MARK: Data request
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

func dataToJson(_ data: Data) throws -> JSON {
    do {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON else {
            throw GMusicError.unknownJsonStructure
        }
        return json
    } catch let error {
        throw GMusicError.jsonParseError(error)
    }
}

func dataRequest(for session: URLSession) -> (URLRequest) -> Single<Data> {
    return session
        |> (dataRequest |> curry |> flip)
}

func jsonRequest(for session: URLSession) -> (URLRequest) -> Single<JSON> {
    return { dataRequest($0, in: session).map(dataToJson) }
}

func jsonRequest(from dataRequest: Single<Data>) -> Single<JSON> {
    return dataRequest.map(dataToJson)
}
