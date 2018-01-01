//
//  Ref.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 01.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation

public struct GMusicRef: Codable {
	let kind: String
	let url: URL
	let aspectRatio: Int
	let autogen: Bool
}
