//
//  MovieView.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class MovieView: UIView {

    @IBOutlet weak var backdrop: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    var movie : WMovie? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI() {
        title.text = movie?.title
        overview.text = movie?.overview
        releaseDate.text = "Release : \(String(describing: movie?.release_date.description.components(separatedBy: " ")[0]))"
        
        let movieId = movie?.id
        var imageURL: URL?
        imageURL = movie?.getFullBackdropImageURL()
        if imageURL == nil {
            imageURL = movie?.getFullPosterImageURL()
        }
        
        DispatchQueue.global(qos: .userInteractive ).async { [weak self] in
            if let url = imageURL ,
                let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async { [weak self ] in
                    if movieId == self?.movie?.id {
                        self?.backdrop.image = UIImage(data: imageData)
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self ] in
                    self?.backdrop.image = UIImage(named: "imageNotFound")
                }
            }
            
        }
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        updateUI()
    }
    

}
