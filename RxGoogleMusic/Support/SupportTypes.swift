//
//  SupportFunctions.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 10/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

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
