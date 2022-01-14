//
//  ViewController.swift
//  sample-app-ios
//
//  Created by Adam Mcgrath on 14/01/2022.
//

import UIKit
import Auth0

class ViewController: UIViewController {

    override func viewDidLoad() {
    }

    @IBAction func onClick(_ sender: UIButton) {
        Auth0
            .webAuth()
            .logging(enabled: true)
            .start { result in
                switch result {
                case .success(let credentials):
                    let alert = UIAlertController(title: "Alert", message: credentials.idToken, preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }
    
}
