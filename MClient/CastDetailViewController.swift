//
//  CastDetailViewController.swift
//  MClient
//
//  Created by gupta.a on 10/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class CastDetailViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    var cast: WCastPeople?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = cast?.name
        // Do any additional setup after loading the view.
    }

}
