//
//  NewCastCell.swift
//  MClient
//
//  Created by gupta.a on 07/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class NewCastCell: UICollectionViewCell {
    @IBOutlet weak var poster: UIImageView!

    @IBOutlet weak var name: UILabel!
    
    var cast: WCastPeople? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        
        poster.image = UIImage(named: "darkLoading")
        let castId = cast?.id
        let imageURL = cast?.getFullProfileImageURL()
        
        DispatchQueue.global(qos: .userInteractive ).async { [weak self] in
            if let url = imageURL ,
                let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async { [weak self ] in
                    if castId == self?.cast?.id {
                        self?.poster.image = UIImage(data: imageData)
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self ] in
                    self?.poster.image = UIImage(named: "imageNotFound")
                }
            }
            
        }
        
        
        
        name.text = cast?.name
        
        
    }
}
