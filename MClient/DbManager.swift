//
//  DbManager.swift
//  MClient
//
//  Created by gupta.a on 27/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DbManager {
 
    private static var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
//    static let readContext : NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).rContext
    
    static let readContext : NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    static let saveContext : NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).sContext

    static let writeContext : NSManagedObjectContext =  (UIApplication.shared.delegate as! AppDelegate).wContext
    
    
    // The following methods are to be used by CastDetailsViewController
    
    static func getMovieCredits(forPersonWithId id : Int ) -> [WMovie] {
        // Do work on main thread
        var temp_movie_credits : [WMovie] = []
        readContext.performAndWait {
            let db_person = Person.find(id : id , in : readContext)
            if let db_movie_credits = db_person?.movieCredits?.sortedArray(using:[NSSortDescriptor(key: "id", ascending: true)]) as? [Movie] {
                for current_movie in db_movie_credits {
                    temp_movie_credits.append(WMovie(credit: current_movie))
                }
            }

        }
        
        return temp_movie_credits
    }
    
    static func getPerson(withId id : Int) -> WCastPeople? {
        // Do work on main thread

        var person: WCastPeople?
        readContext.performAndWait {
            let db_person = Person.find(id: id, in: readContext)
            if db_person != nil {
                person = WCastPeople(person: db_person!)
            }
        }
        
        return person
    }
    
    static func saveAdditionalPersonDetails(_ person : WCastPeople){
        // The function saves the additional details only if person already
        // has partial details in DB
        // Do work on background thread
        writeContext.perform {
            let db_person = Person.addAditionalDetails(person, in: writeContext)
            do {
                try writeContext.save()
                if db_person != nil {
                    print("Additional person details updated")
                } else {
                    print("Unable to update additional person details")
                }
            } catch {
                print("Error while saving additional person details")
                print(error.localizedDescription)
            }
        }
    }
    
    // The following merhods are to be used by WatchlistViewController
    static func synchronizeWatchlistInDb(with movies : [WMovie]) {
        // Do work on background thread
        writeContext.perform {
            for current_movie in movies {
                let _ = Movie.updateWatchlistInDb(with: current_movie, action: .ADD, in : writeContext)
                try? writeContext.save()
//                print("Saving watchlist movie : \(current_movie.title) , id : \(current_movie.id)")
            }
        }
    }
    
    // The following merhods are to be used by MovieDetailsViewController
    
    static func isMovieAvailableInWatchlist(id : Int ) -> Bool {
        // Do work on main thread
        var returnValue : Bool = false
        readContext.performAndWait {
            if let db_movie = Movie.find(id: id, in: readContext) ,
            db_movie.isInWatchlist
            {
                returnValue = true
            } else {
                returnValue = false
            }
        }

        return returnValue
    }
    
    static func getMovieCast(movieId id : Int ) -> [WCastPeople] {
        // This needs to run on main thread
        var temp_cast = [WCastPeople]()
        readContext.performAndWait {
            let db_movie = Movie.find(id : id , in : readContext)
            if let db_cast = db_movie?.cast?.sortedArray(using:[NSSortDescriptor(key: "id", ascending: true)]) as? [Person] {
                for current_person in db_cast {
                    temp_cast.append(WCastPeople(person: current_person))
                }
            }
        }
        
        return temp_cast
    }
    
    
    static func saveMovieCast( _ cast : [WCastPeople] , forMovieWithId id : Int ) {
        // This needs to run on Background thread

        writeContext.perform {
            if let _ = Movie.addCast(cast, forMovieWithId:  id , in : writeContext )
            {
                do {
                    try writeContext.save()
                    print("Movie Cast saved to Db")
                } catch {
                    print("Error while saving MovieCast")
                    print(error.localizedDescription)
                }
            }
            
        }
        
        
    }
    
    static func updateWatchlist(with movie : WMovie , action : WatchlistAction )
    {
        // This needs to run on background thread
        writeContext.perform {
            let _ = Movie.updateWatchlistInDb(with: movie, action: action , in : writeContext)
            do {
                try writeContext.save()
                print("Watchlist : Movie updation in DB succeeded")
               
            } catch {
                print("WAtchlist updation in Db Failed")
                print(error.localizedDescription)
            }
        }
        
    }
    
    // The following method(s) are to be used by UpcomingViewController
    
    static func saveUpcomingMovies( _ movies : [WMovie]) {
        writeContext.perform {
            for current_movie in movies {
                let _ = Movie.create(using: current_movie, in: writeContext)
                try? writeContext.save()
            }
        }

    }
    
    static func getLatestDate() -> Date {
        var date = Date()
        readContext.performAndWait {
            date =  Movie.getLatestDate(in: readContext)
        }
        return date
    }
    

    /* The following methods are to be used by NowPlaying */
    
    
    static func saveNowPlayingMovies(_ movies : [WMovie]) {
        
        writeContext.perform {
            for current_movie in movies {
                let db_movie = Movie.create(using: current_movie, in: writeContext)
                db_movie?.isPlaying = true
                try? writeContext.save()
            }
        }
    }
    
    static func cleanup(preserve movies : [WMovie]) {
//         Both these methods need to work synchronously . Ensure that
        writeContext.performAndWait {
            updateOldMovies(except : movies)
            deleteOldCast()
        }
    }
    
    private static func updateOldMovies(except movies : [WMovie]) {
        // This needs to run on background thread
    // Deletes or retains old movies as needed
        writeContext.perform {
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            let release_date_predicate =  NSPredicate(format: "release_date <= %@", Date() as NSDate)
            let not_in_watchlist_predicate = NSPredicate(format: "isInWatchlist = %@", false as CVarArg)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [release_date_predicate, not_in_watchlist_predicate])
            // ADd predicate
            do {
                var delete_count : Int = 0
                let matches = try writeContext.fetch(request)
                if matches.count > 0 {
                    for current_match in matches {
                        if !doNetworkQueryResults(movies, contain: current_match) {
                            writeContext.delete(current_match)
                            try writeContext.save()
                            delete_count = delete_count + 1
                        }
                    }
                }
                print("Removed \(delete_count) old movies")
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    private static func doNetworkQueryResults(_ movies: [WMovie], contain db_movie : Movie) -> Bool {
        for current_movie in movies {
            if current_movie.id == Int(db_movie.id) {
                return true
            }
        }
        return false
    }
    
    private static func deleteOldCast() {
        // Deleting Casts with no movie Credits Left
        writeContext.perform {
            let cast_request : NSFetchRequest<Person> = Person.fetchRequest()
            cast_request.predicate = NSPredicate(format: "movieCredits.@count == 0 " )  // Issue here
            do {
                let matches = try writeContext.fetch(cast_request)
                if matches.count > 0 {
                    for current_match in matches {
                        writeContext.delete(current_match)
                    }
                    try writeContext.save()
                    print("Deleted \(matches.count) People with no movieCredits")
                }
            }
            catch {
                print("Error in removing cast with no MovieCredits")
                print(error.localizedDescription)
            }
        }
    }
    
}
