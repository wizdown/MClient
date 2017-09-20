//
//  Constants.swift
//  MClient
//
//  Created by gupta.a on 30/08/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation



class Constants {
    
    static let base_url: String = "api.themoviedb.org"
    static let url_scheme="https"
    static let api_key: String = "71c4e026a81c526c33013f530de0d158"
    static let basePosterImageURL: String = "https://image.tmdb.org/t/p/w300"  // Take care of quality if possible
    static let baseBackdropImageUrl: String="https://image.tmdb.org/t/p/w1280"
    
    static let baseCastProfileImageUrl: String = "https://image.tmdb.org/t/p/w300"
    static let baseCastProfileBackdropImageUrl: String = "https://image.tmdb.org/t/p/w1280"

    
    static let movieCellReuseIdentifier = "movieCell"
    static let castCellReuseIdentifier = "castCell"
    static let searchHeaderReuseIdentifier = "searchHeader"
    
    static let key_account_id = "accountId"
    static let key_session_id = "sessionId"
    static let key_username = "username"
    
    static let notFound = "Not Found"

    static let gender = [
        1: "Female",
        2: "Male"
    ]
    
    static let genre = [
    28 : "Action",
    12: "Adventure",
    16: "Animation",
    35: "Comedy",
    80: "Crime",
    99: "Documentary",
    18: "Drama",
    10751: "Family",
    14: "Fantasy",
    36: "History",
    27: "Horror",
    10402: "Music",
    9648: "Mystery",
    10749: "Romance",
    878: "Science Fiction",
    10770: "TV Movie",
    53: "Thriller" ,
    10752: "War",
    37: "Western"
    ]
    
//    static let requestType = [
//        "movieSearch" : "/3/search/movie"
//    ]
    
    static func getUrlPathForMovieCreditsRequest(castId: Int) -> String {
        var url_path = "/3/person/"
        url_path.append(String(castId))
        url_path.append("/movie_credits")
        return url_path
    }
    
    static func getUrlPathForCastForMovieRequest ( movieId: Int ) -> String {
        var url_path = "/3/movie/"
        url_path.append(String(movieId))
        url_path.append("/credits")
        return url_path
    }
    
    static func getUrlPathForWatchlistRequest() -> String? {
        var url_path = "/3/account/"
        if let accountId = UserDefaults.standard.string(forKey: Constants.key_account_id) {
            url_path.append(accountId)
            url_path.append("/watchlist")
            return url_path
        } else {
            return nil
        }
    }
    
    enum requestType : String {
        case movieSearch = "/3/search/movie"
        case nowPlaying =  "/3/movie/now_playing"
        case upcoming = "/3/movie/upcoming"
        case discoverMovie = "/3/discover/movie"
        case castDetails = "/3/person/"
        
    }
    enum queryParameter : String {
        case api_key = "api_key"
        case language = "language"
        case query = "query"
        case include_adult = "include_adult"
        case page = "page"
        case include_video = "include_video"
        case primary_release_date_gte = "primary_release_date.gte"
        case sort_by = "sort_by"
        case session_id = "session_id"
    }
    
}

struct NeedPersistence {
    var _required : Bool = false
     var stepCount : Int = 0
    var required: Bool {
        get {
            if _required , stepCount <= 2 {
                return true
            }
            else {
                    return false
            }
        }
    }
    
    init(isNeeded : Bool ) {
        _required = isNeeded
    }
    
    
    mutating func incrStepCount() {
        if _required , stepCount < 3 {
            stepCount = stepCount + 1
        }
    }
    
}
