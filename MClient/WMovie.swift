
//
//  WMovie.swift
//  MClient
//
//  Created by gupta.a on 29/08/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation

struct WMovie {
    
    let poster_path: String?
    let backdrop_path: String?
    let original_language: String?
    let release_date: Date?
    
    let original_title: String
    let overview: String
    let popularity: Double
    let id: Int
    let title: String
    let genre : String

    
 

    
    func getFullPosterImageURL() -> URL? {
        var baseImageURL: String = Constants.basePosterImageURL
        if let poster_path = self.poster_path {
            baseImageURL.append(poster_path)
            return URL(string: baseImageURL)
        }
        return nil
    }
    
    func getFullBackdropImageURL() -> URL? {
        var baseImageURL: String = Constants.baseBackdropImageUrl
        if let backdrop_path = self.backdrop_path {
            baseImageURL.append(backdrop_path)
            return URL(string: baseImageURL)
        }
        return nil
    }
    
    
}

extension WMovie {
    init?(json: [String: Any]){
        guard
            let popularity = json["popularity"] as? Double,
            let id = json["id"] as? Int,
            let genre_ids = json["genre_ids"] as? [Int],
            let title = json["title"] as? String
            else {
                return nil
        }
        
//        print("GUARD CLEARED")
        
        if let backdrop_path = json["backdrop_path"] as? String ,
            backdrop_path.characters.count > 0 {
            self.backdrop_path = backdrop_path
        } else {
            self.backdrop_path = nil
        }
        
        if let poster_path = json["poster_path"] as? String ,
            poster_path.characters.count > 0 {
            self.poster_path = poster_path
        }
        else {
            self.poster_path = nil
        }

        
        var movie_genre: String = ""
        for current_genre_id in genre_ids {
            if let current_genre = Constants.genre[current_genre_id] {
                if movie_genre.characters.count > 0 {
                    movie_genre.append(", ")
                }
                movie_genre.append(current_genre)
            }
        }
        
        if(movie_genre.characters.count == 0) {
            self.genre = Constants.notFound

        }
        else {
            self.genre = movie_genre
        }

        //Release Date Initialization
//        print(json["releaseDate"])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let release_date_string = json["release_date"] as? String ,
            release_date_string.characters.count > 0 ,
            let release_date = dateFormatter.date(from:release_date_string) {
            self.release_date = release_date

        }else {
            self.release_date = nil
        }
        
        if  let overview = json["overview"] as? String,
            overview.characters.count > 0 {
            self.overview = overview
        } else {
            self.overview = Constants.notFound
        }
        
        if let original_title = json["original_title"] as? String ,
            original_title.characters.count > 0{
            self.original_title = original_title
        } else {
            self.original_title = Constants.notFound
        }
        
        if let original_language = json["original_language"] as? String ,
            original_language.characters.count > 0 {
            self.original_language = original_language
        }
        else {
            self.original_language = Constants.notFound
        }

        
        self.popularity = popularity
        self.id = id
        if title.characters.count > 0 {
            self.title = title
        } else {
            self.title = Constants.notFound
        }
        
    }
    
    init(credit: Movie) {
        self.backdrop_path = credit.backdrop_path
        self.genre = credit.genre!
        self.id = Int(credit.id)
        self.overview = credit.overview!
        self.popularity = credit.popularity
        self.poster_path = credit.poster_path
        self.release_date = credit.release_date as Date?
        self.title = credit.title!
        self.original_title = Constants.notFound
        self.original_language = Constants.notFound
    }
}
