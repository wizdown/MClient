//
//  People.swift
//  MClient
//
//  Created by gupta.a on 13/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

class People: NSManagedObject {
    static func findOrCreatePeople(matching people: WCastPeople , in context: NSManagedObjectContext) throws -> People {
    let request : NSFetchRequest<People> = People.fetchRequest()
        request.predicate = NSPredicate(format: "id = %ld", Int64(people.id))
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1 , "People.findOrCreatePeople -- DB Inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let _people = People(context: context)
        _people.id = Int64(people.id)
        _people.biography = people.biography
        _people.date_of_birth = people.date_of_birth as NSDate?
        _people.gender = people.gender
        _people.name = people.name
        _people.place_of_birth = people.place_of_birth
        _people.profile_path = people.profile_path
        
        return _people
    }
    
    static func findOrCreateMovieCredits(matching people: WCastPeople, movies: [WMovie] , in context: NSManagedObjectContext ) throws -> People {
        // the following code assumes that a People object has already been created
        // before adding his/her movie credits
        
        let request: NSFetchRequest<People> = People.fetchRequest()
        request.predicate = NSPredicate(format: "id = %ld" , Int64(people.id))
        var matches: [People]
        do {
            matches = try context.fetch(request)
            assert(matches.count == 1, "People.findOrCreateMovieCredits -- DB InConsistency")
        }
        catch {
            throw error
        }
        for current_movie in movies {
            do{
                let new_movie = try Movie.findOrCreateMovie(matching: current_movie, in: context)
                matches[0].addToMovieCredits(new_movie)
            }catch{
                print(error.localizedDescription)
            }
        }
        return matches[0]
    }
}
