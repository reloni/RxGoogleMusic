//
//  ViewController.swift
//  ExampleApp
//
//  Created by Anton Efimenko on 03.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import RxGoogleMusic

class ViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func authenticate(_ sender: Any) {
		let controller = GMusicAuthenticationController { [unowned self] result in
			switch result {
			case .userAborted: print("aborted")
			case .authenticated(let token): self.showLibrary(accessToken: token)
			case .error(let e): self.showErrorAlert(e)
			}
		}
		present(controller, animated: true, completion: nil)
	}
	
	func showErrorAlert(_ error: Error) {
		let message = getMessage(for: error)
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		presentedViewController?.present(alert, animated: true, completion: nil)
	}
	
	func getMessage(for error: Error) -> String {
		guard let gmusicError = error as? GMusicError else { return error.localizedDescription }
		switch gmusicError {
		case .unableToRetrieveAuthenticationUri: return "Unable to load authentication URI"
		case .jsonParseError(let e): return "Error while parsing JSON (\(e.localizedDescription))"
		case .urlRequestError: return "Error while performing URL request"
		case .urlRequestLocalError(let e): return e.localizedDescription
		default: return "Unknown error"
		}
	}

	
	func showLibrary(accessToken token: GMusicToken) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LibraryController") as! LibraryController
		
		controller.client = GMusicClient(token: token,
										 session: URLSession(configuration: URLSessionConfiguration.default),
										 locale: Locale.current)
		
		present(controller, animated: true, completion: nil)
	}
}
