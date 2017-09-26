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
    private var autoIncrPageNo: Bool
        
    var lastSuccessfulRequestNumber: Int {
        get {
            return currentPageNumber
        }
    }
    
    init( urlComponents: URLComponents , require_paging: Bool , autoIncrPageNo: Bool ) {
        self._urlComponents = urlComponents
        self.require_paging = require_paging
        self.autoIncrPageNo = autoIncrPageNo
    }
    
    private func setMaxPageNumber(to pageNo: Int) {
        maxPageNumber = pageNo
    }
    
    private var _urlComponents: URLComponents?

    var url: URL? {
        
        get {
            if _urlComponents == nil  {
                return nil
            } else{
                if self.require_paging {
                    if currentPageNumber == maxPageNumber {
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
                else {
                    if let debug_url = _urlComponents!.url {
                        print(debug_url)
                    }
                    return _urlComponents!.url
                }
            }
        }
    }
    
    static func castDetailsRequest(castId: Int ) -> WMRequest? {
        
        var url_path = Constants.requestType.castDetails.rawValue
        url_path.append(String(castId))
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = url_path
        urlComponents.queryItems = [URLQueryItem(name: Constants.queryParameter.api_key.rawValue, value: Constants.api_key ), URLQueryItem(name: Constants.queryParameter.language.rawValue, value:
            "en-US")]
        return WMRequest(urlComponents: urlComponents, require_paging: false , autoIncrPageNo: false )
        
    }
    
    static func movieCreditsRequest( castId : Int ) ->WMRequest? {
        let url_path = Constants.getUrlPathForMovieCreditsRequest(castId: castId)
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = url_path
        urlComponents.queryItems = [URLQueryItem(name: Constants.queryParameter.api_key.rawValue, value: Constants.api_key ), URLQueryItem(name: Constants.queryParameter.language.rawValue, value:
            "en-US")]
        return WMRequest(urlComponents: urlComponents, require_paging : false , autoIncrPageNo : false )
    }
  
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
        
        let request: WMRequest = WMRequest(urlComponents: urlComponents, require_paging: true , autoIncrPageNo: true )
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
        let request: WMRequest = WMRequest(urlComponents: urlComponents, require_paging: true ,autoIncrPageNo: true)
        
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
        let request: WMRequest = WMRequest(urlComponents: urlComponents , require_paging : false , autoIncrPageNo: false)
        
        return request
    }
    
    static func castForMovieRequest(movieId: Int) -> WMRequest? {
        
        let url_path = Constants.getUrlPathForCastForMovieRequest(movieId: movieId)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = url_path
        urlComponents.queryItems = [URLQueryItem(name: Constants.queryParameter.api_key.rawValue, value: Constants.api_key )]
        return WMRequest(urlComponents: urlComponents , require_paging : false , autoIncrPageNo : false )
    }
    
    static func getUpdateWatchlistRequest() -> WMRequest? {
        guard
            let url_path = Constants.getUrlPathForWatchlistUpdateRequest() ,
            let session_id = UserDefaults.standard.string( forKey: Constants.key_session_id )
            else {
                return nil
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = url_path
        
        let api_key = URLQueryItem(name: Constants.queryParameter.api_key.rawValue , value: Constants.api_key)
        let sessionId = URLQueryItem(name: Constants.queryParameter.session_id.rawValue, value: session_id)
        urlComponents.queryItems = [ api_key, sessionId ]
        let request: WMRequest = WMRequest(urlComponents: urlComponents, require_paging: false, autoIncrPageNo: false)
        
        return request
        
    }
    
    static func getWatchlistRequest() -> WMRequest? {
        guard
            let url_path = Constants.getUrlPathForWatchlistRequest() ,
            let session_id = UserDefaults.standard.string(forKey: Constants.key_session_id)
            else {
                return nil
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.url_scheme
        urlComponents.host = Constants.base_url
        urlComponents.path = url_path
        
        let api_key = URLQueryItem(name: Constants.queryParameter.api_key.rawValue , value: Constants.api_key)
        let sessionId = URLQueryItem(name: Constants.queryParameter.session_id.rawValue, value: session_id)
        let lang = URLQueryItem(name: Constants.queryParameter.language.rawValue, value: "en-US" )
        let sort_criteria = URLQueryItem(name: Constants.queryParameter.sort_by.rawValue, value: "created_at.asc")
        
        urlComponents.queryItems = [api_key, lang, sessionId, sort_criteria]
        
        let request : WMRequest = WMRequest(urlComponents: urlComponents, require_paging: true, autoIncrPageNo: true)
        return request
        
    }
    
     func performRequest(completion: @escaping ([WMovie]) -> Void ){

        if let request_url = url {
            let task = URLSession.shared.dataTask(with: request_url) {(data, response, error) in
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
                    
                    if self.require_paging ,
                        self.autoIncrPageNo {
                        self.currentPageNumber = self.currentPageNumber + 1
                    }
                    
                }
                completion(movies)
            }
            // put handler here
            task.resume()
        }
        
    }
    
    func performGetCastForAMovieRequest(completion: @escaping ([WCastPeople]) -> Void ){
        
        var cast: [WCastPeople] = []
        let url: URL = self.url!
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
    
 
    
    func updateWatchlist( with movie: WMovie , status : WatchlistAction, completion : @escaping (Bool) -> Void ) {
        var params : [String: Any] = [:]
        params["media_type"] = "movie"
        params["media_id"] = movie.id
        switch status {
            case .ADD : params["watchlist"] = true
            case .REMOVE : params["watchlist"] = false
        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []),
            let url = self.url {
            let postRequest = NSMutableURLRequest(url: url)
            postRequest.httpMethod = "POST"
            postRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
            postRequest.httpBody = jsonData
            

            let task = URLSession.shared.dataTask(with: postRequest as URLRequest) {
                data, response , error in
                if error != nil {
                    print(error!.localizedDescription)
                    completion(false)
                } else {
                    var success: Bool = false
                    
                    if let valid_data = data ,
                    let json = try? JSONSerialization.jsonObject(with: valid_data, options: [] ) as? [String: Any],
                    let status_code = json!["status_code"] as? Int {
                        print("status code : \(status_code)")
                        switch status {
                        case .ADD : if status_code == 1 || status_code == 12 {
                                        success = true
                                    }
                        case .REMOVE : if status_code == 13 {
                                            success = true
                                        }
                        }
                        completion(success)
                    }
                    
                }
            }
            task.resume()

        }
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
