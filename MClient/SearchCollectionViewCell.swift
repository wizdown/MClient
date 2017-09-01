//
//  SearchCollectionViewCell.swift
//  MClient
//
//  Created by gupta.a on 29/08/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
  
    @IBOutlet weak var posterImage: UIImageView!
    
   
    @IBOutlet weak var titleLabel: UILabel!
    
    var movie: WMovie? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        titleLabel.text = movie?.title
        self.posterImage.image = nil
        DispatchQueue.main.async {
            if let posterImageURL = self.movie?.getFullPosterImageURL() ,
                let imageData = try? Data(contentsOf: posterImageURL) {
                self.posterImage.image = UIImage(data: imageData)
            }
        }
        
    }
    
}
