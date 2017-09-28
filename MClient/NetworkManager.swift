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
        if _request == nil {
            _request = WMRequest.nowPlayingMoviesRequest()
        }
        switch action {
            case .INITIAL :
               if _request?.lastSuccessfulRequestNumber == 0 {
                    _request?.performRequest() {
                        movies in
                        // These 3 tasks need to be done serially. on private queue
                        //This saving needs to be moved to background queue.
                        //Currently its being invoked from bg queue and using main context
                        //Fix this
                        DbManager.cleanup(preserve: movies)
                        DbManager.saveNowPlayingMovies(movies)
                        completion(movies)
                    }
                }
            
            case .MORE :
                _request?.performRequest() {
                    movies in
                    DbManager.saveNowPlayingMovies(movies)
                    completion(movies)
            }
            
        }
    }
    
    func getUpcomingMovies(afterDate date : Date , completion: @escaping ([WMovie]) -> Void  ) {

        _request = WMRequest.upcomingMoviesRequest(forDateAfterThis: date )
        _request?.performRequest() {
            movies in
            DbManager.saveUpcomingMovies(movies)
            completion(movies)
        }
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
    
    // Following two methods are to be used in MovieDetailsViewController
    
    func getMovieCast(forMovieId id : Int , completion: @escaping ([WCastPeople]) -> Void  ) {
         // Persist cast only if movie is already in DB
        _request = WMRequest.castForMovieRequest(movieId: id)
        _request?.performGetCastForAMovieRequest(){
            cast in
            if cast.count > 0 {
                DbManager.saveMovieCast(cast, forMovieWithId: id)
            }
            completion(cast)
        }
    }
    
    func updateWatchlist(withMovie movie : WMovie , action : WatchlistAction , completion: @escaping (Bool, WMovie, WatchlistAction) -> Void){
        _request = WMRequest.getUpdateWatchlistRequest()
        _request?.updateWatchlist(withMovie: movie, status: action) {
            (success , movie, action ) in
            if success {
                DbManager.updateWatchlist(with : movie, action: action)
            }
            completion(success,movie,action)

        }
    }
    
    // Following two methods are to be used in CastDetailsViewController
    
    func getPersonDetails(for person : WCastPeople , completion : @escaping (WCastPeople?) -> Void ) {
        // This fn needs something to decide whether to save the data(person) or not
        _request = WMRequest.castDetailsRequest(castId: person.id)
        _request?.performGetCastDetailsRequest() {
            (person : WCastPeople?) in
            if person != nil {
                DbManager.saveAdditionalPersonDetails(person!)
            }
            completion(person)
        }
    }
    
    func getMovieCredits(forPersonId id : Int , completion : @escaping ([WMovie]) -> Void ) {
        // This fn never saves to CoreData
        _request = WMRequest.movieCreditsRequest(castId: id)
        _request?.performMovieCreditsRequest(completion: completion)
    }
    
    func synchronizeWatchlist() {
        if _request == nil {
            _request = WMRequest.getWatchlistRequest()
        }
        
        _request?.performRequest(){
            ( movies : [WMovie] ) in
            if movies.count > 0 {
                DbManager.synchronizeWatchlistInDb(with : movies)
                self.synchronizeWatchlist()
            }
        }
    }

    
}

