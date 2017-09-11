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
   
    let biography: String?
    let date_of_birth: Date? // Here there might be some ambiguity in some API calls
    let place_of_birth: String?
    let gender: String?
    
    static func performGetCastForAMovieRequest(request: WCRequest, completion: @escaping ([WCastPeople]) -> Void ){
        let url: URL = request.url!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                var cast: [WCastPeople] = []
                var count = 1
                if let data = data ,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    if let jsonArr = json!["cast"] as? [[String: Any]] {
                        for case let result in jsonArr {
                            //                            print("Cast \(count)")
                            //                            print(result)
                            count = count + 1
                            if let person = WCastPeople(json: result) {
                                cast.append(person)
                            }
                        }
                    }
                }
                
                completion(cast)
            }
        }
        
        // put handler here
        task.resume()
    }
    
    static func performGetCastDetailsRequest(request: WCRequest, completion: @escaping (WCastPeople?) -> Void ){
        let url: URL = request.url!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                var cast: WCastPeople? = nil
                if let data = data ,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ,
                    let result = json {
                        if let person = WCastPeople(json: result) {
                            cast = person
                    }
                }
                completion(cast)
            }
        }
        
        // put handler here
        task.resume()
    }

    
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
            let gender = Constants.gender[genderId]{
            self.gender = gender
        } else {
            self.gender = Constants.notFound
        }
        
        if let biography = json["biography"] as? String {
            self.biography = biography
        } else {
            self.biography = Constants.notFound
        }
        
        if let place_of_birth = json["place_of_birth"] as? String {
            self.place_of_birth = place_of_birth
        } else {
            self.place_of_birth = Constants.notFound
        }
        
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
    
    
}
