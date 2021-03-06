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
import RxCocoa

class LibraryController: UIViewController {
	@IBOutlet weak var segmentControl: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
	var client: GMusicClient!
	let bag = DisposeBag()
	
	var playlists = GMusicCollection<GMusicPlaylist>(kind: "")
	var stations = GMusicCollection<GMusicRadioStation>(kind: "")
	var tracks = GMusicCollection<GMusicTrack>(kind: "")
	var favorites = GMusicCollection<GMusicTrack>(kind: "")
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
		tableView.dataSource = self
		
		segmentControl.rx.controlEvent(UIControl.Event.valueChanged)
			.subscribe(onNext: { [weak self] _ in self?.loadData() })
			.disposed(by: bag)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		segmentControl.sendActions(for: UIControl.Event.valueChanged)
	}
	
	func loadData() {
		switch segmentControl.selectedSegmentIndex {
		case 0: loadPlaylists()
		case 1: loadStations()
		case 2: loadTracks()
		case 3: loadFavorites()
		default: return
		}
	}
	
	func loadPlaylists() {
		client.playlists(maxResults: 15, pageToken: playlists.nextPageToken, recursive: false)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] in
				guard let controller = self else { return }
				controller.playlists = controller.playlists.appended(nextCollection: $0)
				},
					   onError: { [weak self] in self?.showErrorAlert($0) },
					   onCompleted: { [weak self] in self?.tableView.reloadData() })
			.disposed(by: bag)
	}
	
	func loadStations() {
		client.radioStations(maxResults: 15, pageToken: stations.nextPageToken, recursive: false)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] in
				guard let controller = self else { return }
				controller.stations = controller.stations.appended(nextCollection: $0)
			},
					   onError: { [weak self] in self?.showErrorAlert($0) },
					   onCompleted: { [weak self] in self?.tableView.reloadData() })
			.disposed(by: bag)
	}
	
	func loadTracks() {
		client.tracks(maxResults: 15, pageToken: tracks.nextPageToken, recursive: false)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] in
				guard let controller = self else { return }
				controller.tracks = controller.tracks.appended(nextCollection: $0)
			},
					   onError: { [weak self] in self?.showErrorAlert($0) },
					   onCompleted: { [weak self] in self?.tableView.reloadData() })
			.disposed(by: bag)
	}
	
	func loadFavorites() {
		client.favorites(maxResults: 15, pageToken: favorites.nextPageToken, recursive: false)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] in
				guard let controller = self else { return }
				controller.favorites = controller.favorites.appended(nextCollection: $0)
				},
					   onError: { [weak self] in self?.showErrorAlert($0) },
					   onCompleted: { [weak self] in self?.tableView.reloadData() })
			.disposed(by: bag)
	}
    
	@IBAction func logOff(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	func showErrorAlert(_ error: Error) {
		let message = getMessage(for: error)
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		present(alert, animated: true, completion: nil)
	}
	
	func getMessage(for error: Error) -> String {
		guard let gmusicError = error as? GMusicError else { return error.localizedDescription }
		switch gmusicError {
		case .unableToRetrieveAuthenticationUri: return "Unable to load authentication URI"
		case .jsonParseError(let e): return "Error while parsing JSON (\(e.localizedDescription))"
		case .unableToRetrieveAccessToken: return "Unable to retrieve access token"
		case .urlRequestError: return "Error while performing URL request"
		case .urlRequestLocalError(let e): return e.localizedDescription
		default: return "Unknown error"
		}
	}

}

extension LibraryController: UITableViewDelegate {
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard tableView.numberOfSections > 0 else { return }
		
		guard tableView.contentSize.height > tableView.frame.size.height else { return }
		guard tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height + 50) else { return }
		
		loadData()
	}
}

extension LibraryController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch segmentControl.selectedSegmentIndex {
		case 0: return playlists.items.count
		case 1: return stations.items.count
		case 2: return tracks.items.count
		case 3: return favorites.items.count
		default: return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch segmentControl.selectedSegmentIndex {
		case 0: return cell(for: playlists.items[indexPath.row], in: tableView)
		case 1: return cell(for: stations.items[indexPath.row], in: tableView)
		case 2: return cell(for: tracks.items[indexPath.row], in: tableView)
		case 3: return cell(for: favorites.items[indexPath.row], in: tableView)
		default: return UITableViewCell()
		}
	}
	
	func cell(for playlist: GMusicPlaylist, in tableView: UITableView) -> TableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
		cell.textLabel?.text = playlist.name
		cell.detailTextLabel?.text = playlist.description
		return cell
	}
	
	func cell(for station: GMusicRadioStation, in tableView: UITableView) -> TableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
		cell.textLabel?.text = station.name
		cell.detailTextLabel?.text = station.description
		return cell
	}
	
	func cell(for track: GMusicTrack, in tableView: UITableView) -> TableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
		cell.textLabel?.text = "\(track.title) - \(track.album)"
		cell.detailTextLabel?.text = track.artist
		return cell
	}
}
