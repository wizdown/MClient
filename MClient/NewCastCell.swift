//
//  NewCastCell.swift
//  MClient
//
//  Created by gupta.a on 07/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import SDWebImage

class NewCastCell: UICollectionViewCell {
    @IBOutlet weak var poster: UIImageView!

    @IBOutlet weak var name: UILabel!
    
    var cast: WCastPeople? {
        didSet{
            updateUI()
        }
    }
    
    private func getAndSetImageFromNetwork() {
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
    }
    
    private func getAndSetImageFromCache() {
        if let imageURL = cast?.getFullProfileImageURL() {
            poster.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "loading"))
            //            poster.sd_setImage(with: imageURL, placeholderimage: UIImage(named: "thumbnail.jpg") )
        }
    }
    
    private func updateUI(){
        name.text = cast?.name

        poster.image = UIImage(named: "loading")
        
        getAndSetImageFromNetwork()
//        getAndSetImageFromCache()
        
    }
}
