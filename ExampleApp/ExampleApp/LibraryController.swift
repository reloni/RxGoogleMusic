//
//  LibraryController.swift
//  ExampleApp
//
//  Created by Anton Efimenko on 07.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import RxGoogleMusic
import RxSwift

class LibraryController: UIViewController {
	@IBOutlet weak var segmentControl: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
	var client: GMusicClient!
	let bag = DisposeBag()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		client.playlists()
			.subscribe(onNext: { print("playlists count: \($0.items.count)") })
			.disposed(by: bag)
	}
    
	@IBAction func logOff(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
}
