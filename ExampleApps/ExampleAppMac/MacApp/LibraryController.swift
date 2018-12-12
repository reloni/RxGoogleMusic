//
//  LibraryController.swift
//  MacApp
//
//  Created by Anton Efimenko on 11/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic
import RxSwift
import RxCocoa

class LibraryController: NSViewController {
    let bag = DisposeBag()
    var client: GMusicClient!

    @IBOutlet weak var segmentControl: NSSegmentedControl!
    @IBOutlet weak var tableView: NSScrollView!
    
    var playlists = GMusicCollection<GMusicPlaylist>(kind: "")
    var stations = GMusicCollection<GMusicRadioStation>(kind: "")
    var tracks = GMusicCollection<GMusicTrack>(kind: "")
    var favorites = GMusicCollection<GMusicTrack>(kind: "")
    
    @objc dynamic var selectedSegment: Int = 0 {
        didSet {
            loadData()
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = title ?? ""
        segmentControl.selectedSegment = selectedSegment
        
        segmentControl.bind(NSBindingName(rawValue: "selectedSegment"), to: self, withKeyPath: "selectedSegment", options: nil)
        
        loadData()
    }
    
    @IBAction func logOff(_ sender: Any) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "LogInController") as! ViewController
        present(controller, animator: ReplaceWindowControllerAnimator())
    }
    
    func loadData() {
        switch selectedSegment {
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
                       onCompleted: { [weak self] in self?.reloadData() })
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
                       onCompleted: { [weak self] in self?.reloadData() })
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
                       onCompleted: { [weak self] in self?.reloadData() })
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
                       onCompleted: { [weak self] in self?.reloadData() })
            .disposed(by: bag)
    }
    
    func reloadData() {
        switch selectedSegment {
        case 0: print(playlists.items.count)
        case 1: print(stations.items.count)
        case 2: print(tracks.items.count)
        case 3: print(favorites.items.count)
        default: return
        }
    }
    
    func showErrorAlert(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = getMessage(for: error)
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
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
