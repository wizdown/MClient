//
//  MovieDetailsViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var movieView: MovieView!
    
    var movie : WMovie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let contents = movie {
            movieView.movie = contents
        }
        // Do any additional setup after loading the view.
    }

}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
