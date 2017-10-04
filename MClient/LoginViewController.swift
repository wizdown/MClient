//
//  LoginViewController.swift
//  MClient
//
//  Created by gupta.a on 12/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var activityIndicator = UIActivityIndicatorView()

    let networkManager = NetworkManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.color = UIColor.black
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        //        print("Spinner Added")
        networkManager.getNewRequestToken(){ token in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.removeFromSuperview()
                if token == nil {
                    print("Token Not found")
                    // Redirect Back To login page
                    self?.performSegue(withIdentifier: "loginToStartupSegue", sender: nil)
                } else {
                    print("Token : \(token!)")
                    let webv = UIWebView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(UIScreen.main.bounds.height))))
                    var urlString = "https://www.themoviedb.org/authenticate/"
                    urlString.append(token!)
                    urlString.append("?redirect_to=app://com.directi.training.mclient")
                    self?.view.addSubview(webv)
                    webv.loadRequest(URLRequest(url: URL(string: urlString)!))
                }
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? StartUpViewController {
            dest.auth = Auth(authFailed: true)
        }
    }
}
