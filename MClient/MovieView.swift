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
    
    @IBOutlet weak var genre: UILabel!
    
    @IBOutlet weak var castCollectionView: CastCollectionView!
    
    var movie : WMovie? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI() {
        
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
        
        title.text = movie?.title
        
        overview.text = movie?.overview
        
        if let release_date = movie?.release_date.description.components(separatedBy: " ")[0] {
                releaseDate.text = "Release : \(release_date)"
        }
        else {
            releaseDate.text = "Release : Not Found"
        }
        
        var movie_genre: String = ""
        if let genre_array = movie?.genre ,
            genre_array.count > 0 {
            for current_genre in genre_array {
                if movie_genre.characters.count > 0 {
                    movie_genre.append(", ")
                }
                movie_genre.append(current_genre)
            }
            genre.text = movie_genre
        } else {
            genre.text = "Not Found"
        }
        
        castCollectionView.movieId = movie?.id
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        updateUI()
    }
    

}
