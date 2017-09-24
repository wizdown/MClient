//
//  WatchlistErrorViewController.swift
//  MClient
//
//  Created by gupta.a on 22/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class WatchlistErrorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func performLoginAction(_ sender: Any) {
        parent?.tabBarController?.performSegue(withIdentifier: "tabbarToStartupSegue", sender: nil )
//        navigationController?.popToRootViewController(animated: true)
    }
}
