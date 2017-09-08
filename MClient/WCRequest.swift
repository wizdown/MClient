//
//  WCRequest.swift
//  MClient
//
//  Created by gupta.a on 07/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation

class WCRequest {
    private let movieId: Int
    
    init(movieId :  Int){
        self.movieId = movieId
    }
    
    var url: URL? {
        get{
            var url_path = Constants.requestType.getCastForMovie_Part_1_of_2.rawValue
            url_path.append(String(movieId))
            url_path.append(Constants.requestType.getCastForMovie_Part_2_of_2.rawValue)
            
            var urlComponents = URLComponents()
            urlComponents.scheme = Constants.url_scheme
            urlComponents.host = Constants.base_url
            urlComponents.path = url_path
            urlComponents.queryItems = [URLQueryItem(name: Constants.queryParameter.api_key.rawValue, value: Constants.api_key )]
            if let debug_url = urlComponents.url {
                print(debug_url)
            }
            return urlComponents.url
        }
    }
    
    static func castForMovieRequest(movieId: Int) -> WCRequest? {
        return WCRequest(movieId: movieId)
    }
    
}
