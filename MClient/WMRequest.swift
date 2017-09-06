//
//  WMRequest.swift
//  MClient
//
//  Created by gupta.a on 01/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation

class WMRequest : NSObject {
    
    //    func movieSearchRequest(forMovie keyword: String, page : Int, completion: @escaping ([WMovie]) -> Void )
    private var currentPageNumber: Int = 1
    private var maxPageNumber: Int = 1 // This value will be updated with each subsequent request made
   
    
    init( urlComponents: URLComponents ) {
        self._urlComponents = urlComponents
    }
    
    var newer: WMRequest? {
        get {
            if currentPageNumber < maxPageNumber {
                currentPageNumber = currentPageNumber + 1
                return self
            } else {
                return nil
            }
        }
    }
    
    
    func setMaxPageNumber(to pageNo: Int) {
        maxPageNumber = pageNo
    }
    
    private var _urlComponents: URLComponents?

    var url: URL? {
        get {
            if _urlComponents == nil {
                return nil
            } else {
                var urlComponents = URLComponents()
                urlComponents.scheme = _urlComponents!.scheme
                urlComponents.host = _urlComponents!.host
                urlComponents.path = _urlComponents!.path
                var queryItems = _urlComponents!.queryItems!
                queryItems.append(URLQueryItem(name: Constants.queryParameter.page.rawValue, value: String(currentPageNumber)))
                urlComponents.queryItems = queryItems
                if let debug_url = urlComponents.url {
                    print(debug_url)
                }
                return urlComponents.url
            }
        }
    }
  
//    static func movieSearchRequest(forMovie keyword: String) -> WMRequest? {
//        if keyword.characters.count == 0 {
//            return nil
//        }
//        var queryString : String = Constants.base_url
//        queryString.append("\(Constants.searchMovie)")
//        queryString.append("?api_key=\(Constants.api_key)&language=en-US&query=\(keyword)&include_adult=false")
//        let request: WMRequest = WMRequest(urlString: queryString)
//        return request
//    }
    static func movieSearchRequest(forMovie keyword: String) -> WMRequest? {
        
        if keyword.characters.count == 0 {
            return nil
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = Constants.requestType.movieSearch.rawValue
        
        
        let api_key = URLQueryItem(name: Constants.queryParameter.api_key.rawValue , value: Constants.api_key)
        let language = URLQueryItem(name: Constants.queryParameter.language.rawValue, value: "en-US")
        let keyword = URLQueryItem(name: Constants.queryParameter.query.rawValue, value: keyword)
        let adult_content = URLQueryItem(name: Constants.queryParameter.include_adult.rawValue, value: "false")

        urlComponents.queryItems = [ api_key , language , keyword , adult_content ]
        
        let request: WMRequest = WMRequest(urlComponents: urlComponents)
        return request
    }
    
    static func nowPlayingMoviesRequest() -> WMRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = Constants.requestType.nowPlaying.rawValue
        
        
        let api_key = URLQueryItem(name: Constants.queryParameter.api_key.rawValue , value: Constants.api_key)
        let language = URLQueryItem(name: Constants.queryParameter.language.rawValue, value: "en-US")
        
        urlComponents.queryItems = [ api_key , language ]
        let request: WMRequest = WMRequest(urlComponents: urlComponents)
        
        return request
    }
    
    
}
