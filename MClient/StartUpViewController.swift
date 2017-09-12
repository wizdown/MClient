//
//  StartUpViewController.swift
//  MClient
//
//  Created by gupta.a on 12/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

struct Auth {
    let authFailed: Bool
    var _authToken: String?
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
                
                getSessionId(token: token) { id in
                    DispatchQueue.main.async { [weak self ] in
                        if let sessionId = id {
                            self?.saveSessionId(id: sessionId, completion: { [weak self ] in
                                self?.removeMessageLoader()
                                self?.performSegue(withIdentifier: "startupToTabSegue", sender: nil)
                            })
                        } else {
                            self?.showError()
                        }
                    }
                }
                
            } else {
                showError()
            }
        }
    }

    
    @IBAction func performSkip(_ sender: Any) {
        performSegue(withIdentifier: "startupToTabSegue" , sender: nil )
    }
    
    private func getSessionId(token : String , completion: @escaping (String?) -> Void) {
        var sessionId: String? = nil
        
        var urlString: String = "https://api.themoviedb.org/3/authentication/session/new?api_key=71c4e026a81c526c33013f530de0d158&request_token="
        urlString.append(token)
        
        let url: URL = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                if let data = data ,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let id = json?["session_id"] as? String
                {
                    sessionId = id
                    print("SessionId : \(id)")
                }
            }
            completion(sessionId)
        }
        
        task.resume()
        
        // get SessionId Here
        // Call completion after procedure irrespective of result
    }
    
    private func saveSessionId(id: String, completion: ()-> Void){
        
        // Save Id here in CoreData here
        print("SessionID Saved")
        
        completion()
    }
    
    
    private func showError() {
        removeMessageLoader()
        loginButton.isEnabled = true
        skipButton.isEnabled = true
        displayMessageLoader(message: "Error", addSpinner: false)
    }
    
    private func displayMessageLoader(message: String , addSpinner : Bool ) {
        
        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = message
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
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
