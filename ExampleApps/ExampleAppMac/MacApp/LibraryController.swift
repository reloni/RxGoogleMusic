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

class GridClipTableView: NSTableView {
    override func drawGrid(inClipRect clipRect: NSRect) { }
    override func drawBackground(inClipRect clipRect: NSRect) { }
    override func reloadData() {
        if numberOfRows > 0 {
            removeRows(at: IndexSet(0..<numberOfRows), withAnimation: NSTableView.AnimationOptions.effectFade)
        }
        
        guard let rows = dataSource?.numberOfRows?(in: self), rows > 0 else { return }
        
        insertRows(at: IndexSet(0..<rows), withAnimation: NSTableView.AnimationOptions.slideDown)
    }
}

class LibraryController: NSViewController {
    let bag = DisposeBag()
    var client: GMusicClient!

    @IBOutlet weak var segmentControl: NSSegmentedControl!
    @IBOutlet weak var tableView: NSTableView!
    
    var playlists = GMusicCollection<GMusicPlaylist>(kind: "")
    var stations = GMusicCollection<GMusicRadioStation>(kind: "")
    var tracks = GMusicCollection<GMusicTrack>(kind: "")
    var favorites = GMusicCollection<GMusicTrack>(kind: "")
    
    var rowsCount: Int {
        switch selectedSegment {
        case 0: return playlists.items.count
        case 1: return stations.items.count
        case 2: return tracks.items.count
        case 3: return favorites.items.count
        default: return 0
        }
    }
    
    @objc dynamic var selectedSegment: Int = 0 {
        didSet {
            loadData()
        }
    }
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
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
        playlists = GMusicCollection<GMusicPlaylist>(kind: "")
        client.playlists(maxResults: 15, pageToken: .begin, recursive: true)
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
        stations = GMusicCollection<GMusicRadioStation>(kind: "")
        client.radioStations(maxResults: 15, pageToken: .begin, recursive: true)
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
        tracks = GMusicCollection<GMusicTrack>(kind: "")
        client.tracks(maxResults: 15, pageToken: .begin, recursive: true)
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
        favorites = GMusicCollection<GMusicTrack>(kind: "")
        client.favorites(maxResults: 15, pageToken: .begin, recursive: true)
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
        tableView.reloadData()
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

extension LibraryController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rowsCount
    }
}

extension LibraryController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch selectedSegment {
        case 0: return cell(for: playlists.items[row], in: tableView, column: tableColumn)
        case 1: return cell(for: stations.items[row], in: tableView, column: tableColumn)
        case 2: return cell(for: tracks.items[row], in: tableView, column: tableColumn)
        case 3: return cell(for: favorites.items[row], in: tableView, column: tableColumn)
        default: return nil
        }
    }
    
    func cell(for playlist: GMusicPlaylist, in tableView: NSTableView, column: NSTableColumn?) -> NSView? {
        let c = cell(in: tableView, for: column)
        switch c?.identifier?.rawValue {
        case "FirstCell": c?.textField?.stringValue = playlist.name
        case "SecondCell": c?.textField?.stringValue = playlist.ownerName
        default: break
        }
        return c
    }
    
    func cell(for station: GMusicRadioStation, in tableView: NSTableView, column: NSTableColumn?) -> NSView? {
        let c = cell(in: tableView, for: column)
        switch c?.identifier?.rawValue {
        case "FirstCell": c?.textField?.stringValue = station.name
        case "SecondCell": c?.textField?.stringValue = station.description ?? ""
        default: break
        }
        return c
    }
    
    func cell(for track: GMusicTrack, in tableView: NSTableView, column: NSTableColumn?) -> NSView? {
        let c = cell(in: tableView, for: column)
        switch c?.identifier?.rawValue {
        case "FirstCell": c?.textField?.stringValue = track.title
        case "SecondCell": c?.textField?.stringValue = "\(track.album) | \(track.artist)"
        default: break
        }
        return c
    }
    
    func cell(in tableView: NSTableView, for column: NSTableColumn?) -> NSTableCellView? {
        if column == tableView.tableColumns[0] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FirstCell"), owner: nil) as? NSTableCellView
        } else if column == tableView.tableColumns[1] {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SecondCell"), owner: nil) as? NSTableCellView
        } else {
            return nil
        }
    }
}
