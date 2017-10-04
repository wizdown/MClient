//
//  StartUpViewController.swift
//  MClient
//
//  Created by gupta.a on 12/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//


//completion: { [weak self ] in
//    self?.removeMessageLoader()
//    self?.performSegue(withIdentifier: "startupToTabSegue", sender: nil)
//})

import UIKit

struct Auth {
    let authFailed: Bool
    private var _authToken: String?
    var authToken: String? {
        get{
            if authFailed == false {
                return self._authToken!
            } else {
                return nil
            }
        }
        set{
            //          self.authToken = newValue
            _authToken = newValue
        }
    }
    
    init(authFailed: Bool, authToken: String?) {
        self.authFailed = authFailed
        self.authToken = authToken
    }
    
    init( authFailed: Bool){
        self.authFailed = authFailed
    }
}

class StartUpViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    private let networkManager = NetworkManager()
    
    var auth: Auth?
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var effectView: UIVisualEffectView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let authOb = auth {
            loginButton.isEnabled = false
            skipButton.isEnabled = false
            // Disable Buttons Here
            displayMessageLoader(message: "Signing In", addSpinner: true)
            
            if let token = authOb.authToken {
                networkManager.login(withToken: token, success: {
                    DispatchQueue.main.async { [weak self] in
                        self?.removeMessageLoader()
                        self?.performSegue(withIdentifier: "startupToTabSegue", sender: nil)                    }
                }, failure: {
                    DispatchQueue.main.async { [weak self] in
                        self?.showError()
                    }
                })
            } else {
                showError()
            }
        }
    }

    
    @IBAction func performSkip(_ sender: Any) {
        performSegue(withIdentifier: "startupToTabSegue" , sender: nil )
    }
    
    private func showError() {
        removeMessageLoader()
        loginButton.isEnabled = true
        skipButton.isEnabled = true
        displayMessageLoader(message: "Error", addSpinner: false)
    }
    
    private func displayMessageLoader(message: String , addSpinner : Bool ) {
        
        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = message
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        strLabel.textColor = UIColor(white: 0.1 , alpha: 0.7)
        
        //        print("View dimensions : \(view.frame.width) , \(view.frame.height)")
        //        print("View mids : \(view.frame.midX) , \(view.frame.midY)")
        effectView?.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.height*(3/4) - strLabel.frame.height/2 , width: 160, height: 46)
        effectView?.layer.cornerRadius = 15
        effectView?.layer.masksToBounds = true
        
        if addSpinner {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            activityIndicator.startAnimating()
            effectView?.addSubview(activityIndicator)
        }
        effectView?.addSubview(strLabel)
        view.addSubview((effectView)!)
    }
    
    private func removeMessageLoader(){
        effectView?.removeFromSuperview()
    }
    
}
