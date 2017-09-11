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
   
    
}
