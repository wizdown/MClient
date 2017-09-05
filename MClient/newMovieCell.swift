//
//  newMovieCell.swift
//  MClient
//
//  Created by gupta.a on 05/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class newMovieCell: UICollectionViewCell {

    @IBOutlet weak var poster: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    var movie: WMovie? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        title.text = movie?.title
        poster.image = UIImage(named: "loading")
        let movieId = movie?.id
        
        DispatchQueue.global(qos: .userInteractive ).async { [weak self] in
            if let posterImageURL = self?.movie?.getFullPosterImageURL() ,
                let imageData = try? Data(contentsOf: posterImageURL) {
                DispatchQueue.main.async { [weak self ] in
                    if movieId == self?.movie?.id {
                        self?.poster.image = UIImage(data: imageData)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.poster.image = UIImage(named: "imageNotFound")
                }
            }
            
        }
        
    }

}
