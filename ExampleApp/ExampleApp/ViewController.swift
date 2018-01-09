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
			}
		}
		present(controller, animated: true, completion: nil)
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
