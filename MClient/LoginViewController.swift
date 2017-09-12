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


    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.color = UIColor.black
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        //        print("Spinner Added")
        
        getRequestToken { [weak self] token in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.removeFromSuperview()
                if token == nil {
                    print("Token Not found")
                    // Redirect Back To login page
                    self?.performSegue(withIdentifier: "backToSegue", sender: nil)
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
    
    func getRequestToken(completion: @escaping (String?) -> Void ){
        var token: String? = nil
        let url: URL = URL(string: "https://api.themoviedb.org/3/authentication/token/new?api_key=71c4e026a81c526c33013f530de0d158")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                if let data = data ,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let request_token = json?["request_token"] as? String
                {
                    token = request_token
                }
            }
            completion(token)
        }
        
        task.resume()
    }

    

}
