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
    
    static var previousRequest: WMRequest?
    
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

    
}

