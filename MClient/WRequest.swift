//
//  WRequest.swift
//  MClient
//
//  Created by gupta.a on 30/08/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import Foundation

class WRequest {
//    func movieSearchRequest(forMovie keyword: String, page : Int, completion: @escaping ([WMovie]) -> Void )
    private var currentPageNumber: Int = 1
    private var maxPageNumber: Int = 1 // This value will be updated with each subsequent request made
    
    func setMaxPageNumber(to pageNo: Int) {
        maxPageNumber = pageNo
    }
    
    var url: URL?
    
}
