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
    let genre : [String]
    let overview: String
    let original_title: String
    let popularity: Double
    let id: Int
    let original_language: String
    let release_date: Date
    let title: String
    
    // To be used in Details
    let runtime: Int?
    
    
    
    static func performMovieSearchRequest(request: WMRequest, completion: @escaping ([WMovie]) -> Void ) {
        
        let url: URL = request.url!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                var movies: [WMovie] = []
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
                        request.setMaxPageNumber(to: page_count)
                    }
                }
                
                completion(movies)
            }
        }
        
        // put handler here
        task.resume()
    }
    
    func getFullPosterImageURL() -> URL? {
        var baseImageURL: String = "https://image.tmdb.org/t/p/w300"
        if let poster_path = self.poster_path {
            baseImageURL.append(poster_path)
            return URL(string: baseImageURL)
        }
        return nil
    }
    

    
    
}

extension WMovie {
    init?(json: [String: Any]){
        guard let overview = json["overview"] as? String,
            let original_title = json["original_title"] as? String,
            let popularity = json["popularity"] as? Double,
            let id = json["id"] as? Int,
            let genre_ids = json["genre_ids"] as? [Int],
            let original_language = json["original_language"] as? String,
            let title = json["title"] as? String
            else {
                return nil
        }
        
//        print("GUARD CLEARED")
        
        if let backdrop_path = json["backdrop_path"] as? String {
            self.backdrop_path = backdrop_path
        } else {
            self.backdrop_path = nil
        }
        
        if let poster_path = json["poster_path"] as? String {
            self.poster_path = poster_path
        }
        else {
            self.poster_path = nil
        }

        
        var temp_genre: [String] = []
        for current_genre_id in genre_ids {
            if let current_genre = Constants.genre[current_genre_id] {
                temp_genre.append(current_genre)
            }
            
        }
        self.genre = temp_genre

        //Release Date Initialization
//        print(json["releaseDate"])
        if let release_date_string = json["release_date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.release_date = dateFormatter.date(from:release_date_string)!

        }else {
            return nil
        }
        
        
        if let time = json["runtime"] as? Int {
            self.runtime = time
        } else {
            self.runtime = nil
        }
        
        
        self.overview = overview
        self.original_title = original_title
        self.popularity = popularity
        self.id = id
        self.original_language = original_language
        self.title = title
        
    }
}
