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

func setJson(key: String, value: Any?) -> (inout JSON) -> Void {
    return { json in
        json[key] = value
    }
}

func jsonToData(_ json: JSON) -> Data? {
    return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
}

func decode<T: Decodable>(_ data: Data) throws -> T {
    return try JSONDecoder().decode(T.self, from: data)
}

func decode<T>(_ data: Data) throws -> GMusicCollection<T> {
    return try JSONDecoder().decode(GMusicCollection<T>.self, from: data)
}

// MARK: Request setters
func setBody(_ body: Data?) -> (inout URLRequest) -> Void {
    return { request in
        request.httpBody = body
    }
}

func setMethod(_ method: HttpMethod) -> (inout URLRequest) -> Void {
    return {
        $0.httpMethod = method.rawValue
    }
}

func setHeader(field: String, value: String?) -> (inout URLRequest) -> Void {
    return { request in
        request.allHTTPHeaderFields?[field] = value
    }
}

func setAuthorization(_ token: String) -> (inout URLRequest) -> Void {
    return setHeader(field: "Authorization", value: "Bearer \(token)")
}

let defaultHeaders = { (request: inout URLRequest) in
    request.allHTTPHeaderFields = [:]
}

let postHeader = defaultHeaders
    <> setMethod(.post)

let postJson = postHeader
    <> setHeader(field: "content-type", value: "application/json")

let postUrlEncoded = postHeader
    <> setHeader(field: "content-type", value: "application/x-www-form-urlencoded")

// MARK: Data request
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
            
            single(.success(data ?? Data()))
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
