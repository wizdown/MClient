//
//  UserProfileViewController.swift
//  MClient
//
//  Created by gupta.a on 22/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController  {

    @IBOutlet weak var containerView: UIView!
    
    private var isWatchListEnabled : Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Watchlist"
        
        verifyLogin()
        if isWatchListEnabled {
            setContainerViewContent(withID: "watchlistFound")
        } else {
            setContainerViewContent(withID: "watchlistError")
        }

        // Do any additional setup after loading the view.
    }
    
    private func setContainerViewContent(withID storyboardID: String) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: storyboardID)
        viewController?.view.frame = containerView.bounds
//        containerView.layer.borderWidth = 1
//        containerView.layer.borderColor = UIColor.black.cgColor
        self.addChildViewController(viewController!)
        containerView.addSubview((viewController?.view)!)
    }
    
    private func verifyLogin() {
        let account_id = UserDefaults.standard.string(forKey: Constants.key_account_id)
        let session_id = UserDefaults.standard.string(forKey: Constants.key_session_id)
        if account_id != nil && session_id != nil {
            isWatchListEnabled = true
        }
    }
    
}
