//
//  NetworkManager.swift
//  MClient
//
//  Created by gupta.a on 26/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation


class NetworkManager {
    private var _request : WMRequest?
    
    private var _previousRequest: WMRequest?
    
    func getNowPlayingMovies(action : RequestAction , completion: @escaping ([WMovie]) -> Void ) {
        switch action {
            case .INITIAL :
                if _request == nil {
                    _request = WMRequest.nowPlayingMoviesRequest()
                    _request?.performRequest(completion: completion)
                } else {
                    if _request?.lastSuccessfulRequestNumber == 0 {
                        _request?.performRequest(completion: completion)
                    }
                }
        case .MORE :
            if _request == nil {
                _request = WMRequest.nowPlayingMoviesRequest()
            }
            _request?.performRequest(completion: completion)
            
        }
    }
    
    func getUpcomingMovies(afterDate date : Date , completion: @escaping ([WMovie]) -> Void  ) {
        _request = WMRequest.upcomingMoviesRequest(forDateAfterThis: date)
        _request?.performRequest(completion: completion)
    }
    
    func getSearchResults(for keyword : String, action : RequestAction,  completion: @escaping ([WMovie]) -> Void ) {
        
        switch action {
            case .INITIAL :
                _request = WMRequest.movieSearchRequest(forMovie: keyword)
                _previousRequest = _request
            case .MORE : break
        }
        
        _request?.performRequest{ (movies: [WMovie]) in
            if self._request == self._previousRequest {
                completion(movies)
            }
        }
        
    }

    
}

