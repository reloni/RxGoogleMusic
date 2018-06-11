//
//  TableViewCell.swift
//  ExampleApp
//
//  Created by Anton Efimenko on 08.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
