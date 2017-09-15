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
    
    static func findOrCreateMovie(matching movie: WMovie , in context : NSManagedObjectContext) throws -> Movie
    {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "id = %ld", Int64(movie.id))
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1 , "Movie.findOrCreate -- DB Inconsistency")
                return matches[0]
            }
        }catch {
            throw error
        }
        let _movie = Movie(context: context)
        _movie.id = Int64(movie.id)
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
    
    
    static func findOrCreateCast(matching movie: WMovie, cast : [WCastPeople] , in context : NSManagedObjectContext) throws -> Movie {
        // The following code assumes that a Movie object has already been created before
        // adding the cast here
        var _movie: Movie
        do {
            _movie  = try Movie.findOrCreateMovie(matching: movie, in: context)
            for current_cast in cast {
                do {
                    let new_cast = try Person.findOrCreatePerson(matching: current_cast, in: context)
                    _movie.addToCast(new_cast)
                }catch {
                    print(error.localizedDescription)
                    throw error
                }
            }
        } catch {
            print(error.localizedDescription)
            throw error
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
    
}
