//
//  WMRequest.swift
//  MClient
//
//  Created by gupta.a on 01/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation

class WMRequest : NSObject {
    
    //    func movieSearchRequest(forMovie keyword: String, page : Int, completion: @escaping ([WMovie]) -> Void )
    private var currentPageNumber: Int = 1
    private var maxPageNumber: Int = 1 // This value will be updated with each subsequent request made
   
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    var newer: WMRequest? {
        get {
            if currentPageNumber < maxPageNumber {
                currentPageNumber = currentPageNumber + 1
                return self
            }else{
                return nil
            }
        }
    }
    
    
    func setMaxPageNumber(to pageNo: Int) {
        maxPageNumber = pageNo
    }

    var url: URL? {
        get {
            urlString.append("&page=\(currentPageNumber)")
            return URL(string: urlString)
        }
    }
    
    private var urlString: String
    
  
    static func movieSearchRequest(forMovie keyword: String) -> WMRequest? {
        if keyword.characters.count == 0 {
            return nil
        }
        var queryString : String = Constants.base_url
        queryString.append("\(Constants.searchMovie)")
        queryString.append("?api_key=\(Constants.api_key)&language=en-US&query=\(keyword)&include_adult=false")
        let request: WMRequest = WMRequest(urlString: queryString)
        return request
    }
    
}
