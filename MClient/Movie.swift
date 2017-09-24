//
//  Movie.swift
//  MClient
//
//  Created by gupta.a on 13/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

class Movie: NSManagedObject {
    
    static func find(matching movie: WMovie , in context : NSManagedObjectContext) -> Movie? {
        let request : NSFetchRequest<Movie> = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "id = %ld", Int64(movie.id))
        do
        {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1 , "Movie.findOrCreate -- DB Inconsistency")
                return matches[0]
            }
            
        }catch{
            print("Error while finding Movie with Id : \(movie.id)")
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func create(using movie: WMovie , in context : NSManagedObjectContext) -> Movie? {
        let db_movie = Movie.find(matching: movie, in: context)
        if db_movie != nil {
            return db_movie
        }
        let _movie = Movie(context: context)
        _movie.id = Int32(movie.id)
        _movie.popularity = movie.popularity
        _movie.backdrop_path = movie.backdrop_path
        _movie.genre = movie.genre
        _movie.overview = movie.overview
        _movie.poster_path = movie.poster_path
        _movie.title = movie.title
        _movie.release_date = movie.release_date as NSDate?
        _movie.timestamp = Date() as NSDate?
        return _movie
    }
    
    static func addCast(for movie: WMovie, cast : [WCastPeople] , in context : NSManagedObjectContext) throws -> Movie? {
        
        let _movie = Movie.find(matching: movie, in: context)
        
        if _movie != nil {
            for current_cast in cast {
                let new_cast = Person.create(matching: current_cast, in: context)
                if new_cast != nil {
                    _movie!.addToCast(new_cast!)
                    
                }
            }
        }
        return _movie
    }
    
    
    // To be used in upcoming request
    static func getLatestDate(in context: NSManagedObjectContext) -> Date {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [ NSSortDescriptor(key: "release_date", ascending: true ) ]
        do {
            let matches = try context.fetch(request)
            if matches.count > 0,
               let date = matches[matches.count-1].release_date as Date? {
                    return date
            } else {
                return Date()
            }
        } catch{
            print(error.localizedDescription)
            return Date()
        }
        
    }
    
    static func updateWatchlistInDb(with movie: WMovie , action : WatchlistAction , in context : NSManagedObjectContext ) -> Movie? {
        
        var _movie: Movie?
        
        if let temp_movie = Movie.find(matching: movie, in: context)
        {
            _movie = temp_movie
        }
        
        if _movie == nil {
            _movie = Movie.create(using: movie, in: context)
        }
        
        if _movie != nil {
            switch action {
            case .ADD :
                _movie!.isInWatchlist = true
            case .REMOVE :
                _movie!.isInWatchlist = false
            }

        }
        return _movie
        }
    
}
