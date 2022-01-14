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
        Auth0
            .webAuth()
            .logging(enabled: true)
            .start { result in
                switch result {
                case .success(let credentials):
                    print(credentials)
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }


}
