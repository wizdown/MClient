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
    
    static let cellResuseIdentifier = "movieCell"

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
    
    enum requestType : String {
        case movieSearch = "/3/search/movie"
        case nowPlaying =  "/3/movie/now_playing"
        case upcoming = "/3/movie/upcoming"
        case discoverMovie = "/3/discover/movie"
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
    }
    
}
