//
//  MovieView.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

enum WatchListButtonProfile {
    case DISABLED
    case READY_TO_ADD
    case READY_TO_REMOVE
}


class MovieView: UIView {
    
    var delegate : WatchlistDelegate?
    var profile : WatchListButtonProfile? {
        didSet{
            updateWatchlistButton()
        }
    }

    @IBOutlet weak var backdrop: UIImageView!
    
    @IBOutlet weak var watchlistButton: UIButton!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    @IBOutlet weak var genre: UILabel!
    
    @IBOutlet weak var castCollectionView: UICollectionView!
    
    var movie : WMovie? {
        didSet{
//            setNeedsDisplay()
            updateUI()
        }
    }
    
    private func updateWatchlistButton() {
        if let buttonProfile = profile {
            switch buttonProfile {
            case .DISABLED :  watchlistButton.backgroundColor = UIColor.gray
                              watchlistButton.setTitle("Add to watchlist", for: UIControlState.normal)
            case .READY_TO_ADD : watchlistButton.backgroundColor = UIColor.blue
                                watchlistButton.setTitle("Add to watchlist", for: UIControlState.normal)
            case .READY_TO_REMOVE : watchlistButton.backgroundColor = UIColor.red
                                watchlistButton.setTitle("Remove from watchlist", for: UIControlState.normal)
            }
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

//    override func draw(_ rect: CGRect) {
//        // Drawing code
//        updateUI()
//    }
 
    @IBAction func performAddToWatchlist(_ sender: Any) {
        
        if let buttonProfile = profile ,
            movie != nil {
            switch buttonProfile {
                case .DISABLED : delegate?.didPerformAddToWatchlist(profile: .DISABLED)
                case .READY_TO_ADD : delegate?.didPerformAddToWatchlist(profile: .READY_TO_ADD)
                case .READY_TO_REMOVE : delegate?.didPerformAddToWatchlist(profile: .READY_TO_REMOVE)
            }
        }
    }
}
