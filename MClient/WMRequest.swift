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
    private var currentPageNumber: Int = 0
    private var maxPageNumber: Int = 1 // This value will be updated with each subsequent request made
    private var require_paging: Bool
    
    var lastSuccessfulRequestNumber: Int {
        get {
            return currentPageNumber
        }
    }
    
    init( urlComponents: URLComponents , require_paging: Bool ) {
        self._urlComponents = urlComponents
        self.require_paging = require_paging
    }
    
    func setMaxPageNumber(to pageNo: Int) {
        maxPageNumber = pageNo
    }
    
    private var _urlComponents: URLComponents?

    var url: URL? {
        get {
            if _urlComponents == nil || currentPageNumber == maxPageNumber{
                return nil
            } else {
                var urlComponents = URLComponents()
                urlComponents.scheme = _urlComponents!.scheme
                urlComponents.host = _urlComponents!.host
                urlComponents.path = _urlComponents!.path
                var queryItems = _urlComponents!.queryItems!
                queryItems.append(URLQueryItem(name: Constants.queryParameter.page.rawValue, value: String(currentPageNumber + 1)))
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
        
        let request: WMRequest = WMRequest(urlComponents: urlComponents, require_paging: true)
        return request
    }
    
    static func nowPlayingMoviesRequest() -> WMRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = Constants.requestType.nowPlaying.rawValue
        
        
        let api_key = URLQueryItem(name: Constants.queryParameter.api_key.rawValue , value: Constants.api_key)
        let language = URLQueryItem(name: Constants.queryParameter.language.rawValue, value: "en-US")
        
        urlComponents.queryItems = [ api_key , language ]
        let request: WMRequest = WMRequest(urlComponents: urlComponents, require_paging: true)
        
        return request
    }
    
    static func upcomingMoviesRequest(forDateAfterThis date: Date) -> WMRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = Constants.requestType.discoverMovie.rawValue
        
        let required_date = (NSCalendar.current.date(byAdding: Calendar.Component.day, value: 1, to: date as Date))!
        
        let api_key = URLQueryItem(name: Constants.queryParameter.api_key.rawValue , value: Constants.api_key)
        let language = URLQueryItem(name: Constants.queryParameter.language.rawValue, value: "en-US")
        let adult_content = URLQueryItem(name: Constants.queryParameter.include_adult.rawValue, value: "false")
        let include_video = URLQueryItem(name: Constants.queryParameter.include_video.rawValue, value: "false")
        let sort_by = URLQueryItem(name: Constants.queryParameter.sort_by.rawValue,value: "release_date.asc")
        let release_date = URLQueryItem(name: Constants.queryParameter.primary_release_date_gte.rawValue,value: required_date.description.components(separatedBy: " ")[0])
        
        urlComponents.queryItems = [ api_key , language , sort_by, adult_content, include_video, release_date]
        let request: WMRequest = WMRequest(urlComponents: urlComponents , require_paging : false)
        
        return request
    }
    
  
    
    static func castForMovieRequest(movieId: Int) -> WCRequest? {
        
        let url_path = Constants.getUrlPathForCastForMovieRequest(movieId: movieId)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = url_path
        urlComponents.queryItems = [URLQueryItem(name: Constants.queryParameter.api_key.rawValue, value: Constants.api_key )]
        return WCRequest(urlComponents: urlComponents)
    }
    
    static func performGetCastForAMovieRequest(request: WCRequest, completion: @escaping ([WCastPeople]) -> Void ){
        
        var cast: [WCastPeople] = []
        let url: URL = request.url!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                var count = 1
                if let valid_data = data ,
                    let json = try? JSONSerialization.jsonObject(with: valid_data, options: []) as? [String: Any] {
                    
                    if let jsonArr = json!["cast"] as? [[String: Any]] {
                        for case let result in jsonArr {
                            //                            print("Cast \(count)")
                            //                            print(result)
                            count = count + 1
                            if let person = WCastPeople(json: result) {
                                cast.append(person)
                            }
                        }
                    }
                }
            }
            completion(cast)

        }
        
        // put handler here
        task.resume()
    }
    
    

    
     func performRequest(completion: @escaping ([WMovie]) -> Void ){
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            var movies: [WMovie] = []
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                var count = 1
                if let data = data ,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    if let jsonArr = json!["results"] as? [[String: Any]] {
                        for case let result in jsonArr {
                            //                            print("Movie \(count)")
                            //                            print(result)
                            count = count + 1
                            if let movie = WMovie(json: result) {
                                movies.append(movie)
                            }
                        }
                    }
                    
                    if let page_count = json!["total_pages"] as? Int {
                        print("Number of pages : \(page_count)")
                        self.setMaxPageNumber(to: page_count)
                    }
                }
                
                if self.require_paging {
                    self.currentPageNumber = self.currentPageNumber + 1
                }
                
            }
            
            completion(movies)
        }
        
        // put handler here
        task.resume()
    }
        
    
    
}
