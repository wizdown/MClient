//
//  WCRequest.swift
//  MClient
//
//  Created by gupta.a on 07/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation

class WCRequest {
    
    private let _urlComponents: URLComponents?
    
    init(urlComponents: URLComponents ){
        self._urlComponents = urlComponents
    }
    
    var url: URL? {
        get{
            if let debug_url = _urlComponents?.url {
                print(debug_url)
            }
            return _urlComponents?.url
        }
    }
    
    static func castDetailsRequest(castId: Int ) -> WCRequest? {
        
        var url_path = Constants.requestType.castDetails.rawValue
        url_path.append(String(castId))
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = url_path
        urlComponents.queryItems = [URLQueryItem(name: Constants.queryParameter.api_key.rawValue, value: Constants.api_key ), URLQueryItem(name: Constants.queryParameter.language.rawValue, value:
            "en-US")]
        return WCRequest(urlComponents: urlComponents)

    }
    
    static func movieCreditsRequest( castId : Int ) ->WCRequest? {
        let url_path = Constants.getUrlPathForMovieCreditsRequest(castId: castId)
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = url_path
        urlComponents.queryItems = [URLQueryItem(name: Constants.queryParameter.api_key.rawValue, value: Constants.api_key ), URLQueryItem(name: Constants.queryParameter.language.rawValue, value:
            "en-US")]
        return WCRequest(urlComponents: urlComponents)
    }
    
    func performGetCastDetailsRequest( completion: @escaping (WCastPeople?) -> Void ){
        let url: URL = self.url!
        var cast: WCastPeople? = nil

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                if let data = data ,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ,
                    let result = json {
                    if let person = WCastPeople(json: result) {
                        cast = person
                    }
                }
            }
            completion(cast)
        }
        // put handler here
        task.resume()
    }
    
    func performMovieCreditsRequest( completion: @escaping ([WMovie]) -> Void ){
        let url: URL = self.url!
        var movies: [WMovie] = []
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                var count = 1
                if let data = data ,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    if let jsonArr = json!["cast"] as? [[String: Any]] {
                        for case let result in jsonArr {
                            //                            print("Movie \(count)")
                            //                            print(result)
                            count = count + 1
                            if let movie = WMovie(json: result) {
                                movies.append(movie)
                            }
                        }
                    }
                }
            }
            completion(movies)
        }
        
        // put handler here
        task.resume()
    }

   
    
}
