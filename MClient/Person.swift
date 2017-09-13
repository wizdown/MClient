//
//  Person.swift
//  MClient
//
//  Created by gupta.a on 13/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

class Person: NSManagedObject {
    
    static func findOrCreatePerson(matching person: WCastPeople , in context: NSManagedObjectContext) throws -> Person {
    let request : NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "id = %ld", Int64(person.id))
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1 , "person.findOrCreatePerson -- DB Inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let _person = Person(context: context)
        _person.id = Int64(person.id)
        _person.gender = person.gender
        _person.name = person.name
        _person.profile_path = person.profile_path
        
        _person.place_of_birth = person.place_of_birth
        _person.date_of_birth = person.date_of_birth as NSDate?
        _person.biography = person.biography
        
        return _person
    }
    
    func hasCompleteInfo(_ person : Person){
        if person.date_of_birth == nil ,
            person.biography == Constants.notFound ,
            person.place_of_birth == Constants.notFound
        {
            
            return false
        }
        return true
    }
    
    static func addAditionalPersonDetails(matching person: WCastPeople, in context: NSManagedObjectContext) throws -> Person {
       // This fn saves extra details of the person that weren't saved in its previous call
        var _person: Person
        do {
            _person = Person.findOrCreatePerson(matching: person, in: context)
            _person.date_of_birth = person.date_of_birth as NSDate?
            _person.biography = person.biography
            _person.place_of_birth = person.place_of_birth
        } catch{
            throw error
        }
        return _person
    }

    
    static func findOrCreateMovieCredits(matching person: WCastPeople, movies: [WMovie] , in context: NSManagedObjectContext ) throws -> Person {
        
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "id = %ld" , Int64(person.id))
        var matches: [Person]
        do {
            matches = try context.fetch(request)
            assert(matches.count == 1, "Person.findOrCreateMovieCredits -- DB InConsistency")
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
