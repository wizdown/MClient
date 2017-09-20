//
//  MovieView.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class MovieView: UIView {
    
    var delegate : WatchlistDelegate?

    @IBOutlet weak var backdrop: UIImageView!
    
    @IBOutlet weak var watchlistButton: UIButton!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    @IBOutlet weak var genre: UILabel!
    
    @IBOutlet weak var castCollectionView: UICollectionView!
    
    var movie : WMovie? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    private func getAndDisplayBackdropImageFromCache(imageURL : URL? ) {
        if let url = imageURL {
            backdrop.sd_setImage(with: url, placeholderImage: UIImage(named: "loading"))
        }
    }
    
//    private func getAndDisplayBackdropImageFromNetwork(imageURL: URL? ) {
//        let movieId = movie?.id
//
//        DispatchQueue.global(qos: .userInteractive ).async { [weak self] in
//            if let url = imageURL ,
//                let imageData = try? Data(contentsOf: url) {
//                DispatchQueue.main.async { [weak self ] in
//                    if movieId == self?.movie?.id {
//                        self?.backdrop.image = UIImage(data: imageData)
//                    }
//                }
//            } else {
//                DispatchQueue.main.async { [weak self ] in
//                    self?.backdrop.image = UIImage(named: "imageNotFound")
//                }
//            }
//            
//        }
//
//    }
    
    private func updateUI() {
        
        backdrop.image = UIImage(named: "loading" )
       
        var imageURL: URL?
        imageURL = movie?.getFullBackdropImageURL()
        if imageURL == nil {
            imageURL = movie?.getFullPosterImageURL()
        }
        
        getAndDisplayBackdropImageFromCache(imageURL: imageURL)
        
        
        title.text = movie?.title
        
        overview.text = movie?.overview
        
        if let release_date = movie?.release_date?.description.components(separatedBy: " ")[0] {
                releaseDate.text = release_date
        }
        else {
            releaseDate.text = Constants.notFound
        }
        
        genre.text = movie?.genre
    }

    override func draw(_ rect: CGRect) {
        // Drawing code
        updateUI()
    }
 
    @IBAction func performAddToWatchlist(_ sender: Any) {
            if movie != nil {
                delegate?.didPerformAddToWatchlist()
            }
    }
}
