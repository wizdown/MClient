//
//  SearchHeaderCell.swift
//  MClient
//
//  Created by gupta.a on 04/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class SearchHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    var message: String? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        label.text = message
    }
}
