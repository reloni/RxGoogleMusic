//
//  SupportFunctions.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 10/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
#if os(iOS)
import UIKit
#endif

func sequenceMap<OldElement, NewElement>(_ map: @escaping (OldElement) throws -> NewElement) ->
    (Observable<OldElement>) -> Observable<NewElement> {
        return {
            return $0.map(map)
        }
}

func sequenceMap<OldElement, NewElement>(_ map: @escaping (OldElement) throws -> NewElement) ->
    (Single<OldElement>) -> Single<NewElement> {
        return {
            return $0.map(map)
        }
}

enum HardwareType {
    case iOS
    case macOS
    
    static var current: HardwareType {
        #if os(iOS)
        return .iOS
        #elseif os(macOS)
        return .macOS
        #else
        fatalError("Unsupported hardware")
        #endif
    }
    
    var model: String { return hardwareModelString }
    var osVersion: String { return osVersionString }
}

private let hardwareModelString: String = {
    var size: Int = 0
    #if os(iOS)
    let type = "hw.machine"
    #elseif os(macOS)
    let type = "hw.model"
    #endif
    sysctlbyname(type, nil, &size, nil, 0)
    var machine = [CChar](repeating: 0, count: Int(size))
    sysctlbyname(type, &machine, &size, nil, 0)
    return String(cString: machine)
}()

private let osVersionString: String = {
    #if os(iOS)
    return UIDevice.current.systemVersion
    #elseif os(macOS)
    return [ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
            ProcessInfo.processInfo.operatingSystemVersion.minorVersion,
            ProcessInfo.processInfo.operatingSystemVersion.patchVersion]
        .map(String.init)
        .joined(separator: ".")
    #else
    fatalError("Unsupported hardware")
    #endif
}()

struct Hmac {
    private static let part1 = Data(base64Encoded: "VzeC4H4h+T2f0VI180nVX8x+Mb5HiTtGnKgH52Otj8ZCGDz9jRWyHb6QXK0JskSiOgzQfwTY5xgLLSdUSreaLVMsVVWfxfa8Rw==")!
    private static let part2 = Data(base64Encoded: "ZAPnhUkYwQ6y5DdQxWThbvhJHN8msQ1rqJw0ggKdufQjelrKuiGGJI30aswkgCWTDyHkTGK9ynlqTkJ5L4CiGGUabGeo8M6JTQ==")!
    private static let key = zip(part1, part2).map { $0 ^ $1 }
    
    static func sign(string: String, salt: Int) -> (sig: String, slt: String) {
        let slt = String(salt)
        
        let context = UnsafeMutablePointer<CCHmacContext>.allocate(capacity: 1)
        CCHmacInit(context, CCHmacAlgorithm(kCCHmacAlgSHA1), key, size_t(key.count))

        CCHmacUpdate(context, string, size_t(string.lengthOfBytes(using: String.Encoding.utf8)))
        CCHmacUpdate(context, slt, size_t(slt.lengthOfBytes(using: String.Encoding.utf8)))
        
        var hmac = Array<UInt8>(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmacFinal(context, &hmac)
        
        let sig = Data(bytes: hmac)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
        
        return (sig: sig, slt: slt)
    }
    
    static var currentSalt: Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
}
