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
	
	var playlists = GMusicCollection<GMusicPlaylist>()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
		tableView.dataSource = self
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadData()
	}
	
	func loadData() {
		switch segmentControl.selectedSegmentIndex {
		case 0: loadPlaylists()
		default: return
		}
	}
	
	func loadPlaylists() {
		client.playlists()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] in
				self?.playlists = $0
				self?.tableView.reloadData()
			})
			.disposed(by: bag)
	}
    
	@IBAction func logOff(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
}

extension LibraryController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch segmentControl.selectedSegmentIndex {
		case 0: return playlists.items.count
		default: return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch segmentControl.selectedSegmentIndex {
		case 0: return cell(for: playlists.items[indexPath.row], in: tableView)
		default: return UITableViewCell()
		}
	}
	
	func cell(for playlist: GMusicPlaylist, in tableView: UITableView) -> TableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
		cell.textLabel?.text = playlist.name
		cell.detailTextLabel?.text = playlist.description
		return cell
	}
}
