//
//  WCastPeople.swift
//  MClient
//
//  Created by gupta.a on 07/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation

struct WCastPeople {
    
    let name: String
    let id: Int
    let profile_path: String?
   
    let biography: String
    let date_of_birth: Date? // Here there might be some ambiguity in some API calls
    let place_of_birth: String
    let gender: String
    

    
    func getFullProfileImageURL() -> URL? {
        var baseImageURL: String = Constants.baseCastProfileImageUrl
        if let profile_path = self.profile_path {
            baseImageURL.append(profile_path)
            return URL(string: baseImageURL)
        }
        return nil
    }
    
    func getFullBackdropImageURL() -> URL? {
        var baseImageURL: String = Constants.baseCastProfileBackdropImageUrl
        if let profile_path = self.profile_path {
            baseImageURL.append(profile_path)
            return URL(string: baseImageURL)
        }
        return nil
    }
    
}

extension WCastPeople {
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
            name.characters.count > 0,
            let id = json["id"] as? Int
            else {
                return nil
        
        }
        if let profile_path = json["profile_path"] as? String ,
            profile_path.characters.count > 0 {
            self.profile_path = profile_path
        } else {
            self.profile_path = nil
        }
        
        self.name = name
        self.id = id
        
        if let genderId = json["gender"] as? Int,
            let gender = Constants.gender[genderId] {
            self.gender = gender
        } else {
            self.gender = Constants.notFound
        }
//
        if let biography = json["biography"] as? String ,
            biography.characters.count > 0 {
            self.biography = biography
        } else {
            self.biography = Constants.notFound
        }
//        self.biography = Constants.notFound
        
        if let place_of_birth = json["place_of_birth"] as? String,
            place_of_birth.characters.count > 0 {
            self.place_of_birth = place_of_birth
        } else {
            self.place_of_birth = Constants.notFound
        }
        
//        self.place_of_birth = Constants.notFound
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date_of_birth_string = json["birthday"] as? String ,
            date_of_birth_string.characters.count > 0 ,
            let date_of_birth = dateFormatter.date(from:date_of_birth_string) {
            self.date_of_birth = date_of_birth
        }else {
            self.date_of_birth = nil
        }
    }
    
    init(person: Person){
        name = person.name!
//        name = "Dummy"
        id = Int(person.id)
        profile_path = person.profile_path
        biography = person.biography!
        date_of_birth = person.date_of_birth as Date?
        place_of_birth = person.place_of_birth!
        gender = person.gender!
    }
    
    
}
