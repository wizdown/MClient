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
    
    // The following merhods are to be used by CastDetailsViewController
    
    static func getMovieCredits(forPersonWithId id : Int ) -> [WMovie] {
        var temp_movie_credits : [WMovie] = []
        if let context = container?.viewContext {
            context.perform {
                let db_person = Person.find(id : id , in : context)
                if let db_movie_credits = db_person?.movieCredits?.sortedArray(using:[NSSortDescriptor(key: "id", ascending: true)]) as? [Movie] {
                    for current_movie in db_movie_credits {
                        temp_movie_credits.append(WMovie(credit: current_movie))
                    }
                }

            }
        }
        return temp_movie_credits
    }
    
    static func getPerson(withId id : Int) -> WCastPeople? {
        var person: WCastPeople?
        if let context = container?.viewContext {
            context.performAndWait {
                let db_person = Person.find(id: id, in: context)
                if db_person != nil {
                    person = WCastPeople(person: db_person!)
                }
            }
        }
        return person
    }
    
    static func saveAdditionalPersonDetails(_ person : WCastPeople){
        // The function saves the additional details only if person already
        // has partial details in DB
        if let context = container?.viewContext {
            context.perform {
                let db_person = Person.addAditionalDetails(person, in: context)
                do {
                    try context.save()
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
    }
    
    // The following merhods are to be used by WatchlistViewController
    static func synchronizeWatchlistInDb(with movies : [WMovie]) {
        if let context = container?.viewContext {
            context.perform {
                for current_movie in movies {
                    let _ = Movie.updateWatchlistInDb(with: current_movie, action: .ADD, in : context)
                    try? context.save()
                }
            }
        }
    }
    

    // The following merhods are to be used by UpcomingViewController

    static func saveUpcomingMovies( _ movies : [WMovie]) {
        if let context = container?.viewContext {
            context.perform {
                for current_movie in movies {
                    let _ = Movie.create(using: current_movie, in: context)
                    try? context.save()
                }
            }
           
        }
    }
    
    // The following merhods are to be used by MovieDetailsViewController
    
    static func isMovieAvailableInWatchlist(id : Int ) -> Bool {
        if let context = container?.viewContext ,
           let db_movie = Movie.find(id: id, in: context) ,
            db_movie.isInWatchlist
        {
            return true
        }
        return false
    }
    
    static func getMovieCast(movieId id : Int ) -> [WCastPeople] {
        // This needs to run on main thread
        var temp_cast = [WCastPeople]()
        if let context = container?.viewContext {
            let db_movie = Movie.find(id : id , in : context)
            if let db_cast = db_movie?.cast?.sortedArray(using:[NSSortDescriptor(key: "id", ascending: true)]) as? [Person] {
                for current_person in db_cast {
                    temp_cast.append(WCastPeople(person: current_person))
                }
            }
        }
        return temp_cast
    }
    
    
    static func saveMovieCast( _ cast : [WCastPeople] , forMovieWithId id : Int ) {
        if let context = container?.viewContext {
            context.perform {
                if let _ = Movie.addCast(cast, forMovieWithId:  id , in : context )
                {
                    do {
                        try context.save()
                        print("Movie Cast saved to Db")
                    } catch {
                        print("Error while saving MovieCast")
                        print(error.localizedDescription)
                    }
                }
                
            }
        }
        
    }
    
    static func updateWatchlist(with movie : WMovie , action : WatchlistAction )
    {
        if let context = container?.viewContext {
            context.perform {
                let db_movie = Movie.updateWatchlistInDb(with: movie, action: action , in : context)
                do {
                    try context.save()
                    if db_movie != nil {
                        print("Watchlist : Movie updation in DB succeeded")
                    } else {
                        print("Watchlist : Movie updation in DB Failed")
                    }
                } catch {
                    print("WAtchlist updation in Db Failed")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
   
    

    /* The following methods are to be used by NowPlaying */
    
    
    static func saveNowPlayingMovies(_ movies : [WMovie]) {
        if let context = self.container?.viewContext {
            context.perform {
                for current_movie in movies {
                    let db_movie = Movie.create(using: current_movie, in: context)
                    db_movie?.isPlaying = true
                    try? context.save()
                }

            }
        }
    }
    
    static func cleanup(preserve movies : [WMovie]) {
        // Both these methods need to work synchronously . Ensure that
        updateOldMovies(except : movies)
        deleteOldCast()
    }
    
    
    private static func updateOldMovies(except movies : [WMovie]) {
        // Deletes or retains old movies as needed
        if let context = container?.viewContext {
            context.perform {
                let request: NSFetchRequest<Movie> = Movie.fetchRequest()
                let release_date_predicate =  NSPredicate(format: "release_date <= %@", Date() as NSDate)
                let not_in_watchlist_predicate = NSPredicate(format: "isInWatchlist = %@", false as CVarArg)
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [release_date_predicate, not_in_watchlist_predicate])
                // ADd predicate
                do {
                    var delete_count : Int = 0
                    let matches = try context.fetch(request)
                    if matches.count > 0 {
                        for current_match in matches {
                            if !doNetworkQueryResults(movies, contain: current_match) {
                                context.delete(current_match)
                                try context.save()
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
        
        container?.performBackgroundTask{ background_context in
            let cast_request : NSFetchRequest<Person> = Person.fetchRequest()
            cast_request.predicate = NSPredicate(format: "movieCredits.@count == 0 " )  // Issue here
            do {
                let matches = try background_context.fetch(cast_request)
                if matches.count > 0 {
                    for current_match in matches {
                        background_context.delete(current_match)
                    }
                    try background_context.save()
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
