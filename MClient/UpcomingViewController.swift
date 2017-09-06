//
//  UpcomingViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

fileprivate var itemsPerRow : CGFloat = 2
fileprivate let sectionInsets = UIEdgeInsets(top: 10.0 , left: 10.0 , bottom: 10.0 , right: 10.0 )

class UpcomingViewController: MoviesCollectionViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func initialize() {
        _collectionView = collectionView
        _navigationViewControllerTitle = "Upcoming Movies"
        _segueIdentifierForMovieDetails = "UpcomingToMovieDetailSegue"
        _movieRequest = WMRequest.upcomingMoviesRequest()
        
    }
    
     override func getResults() {
        var request: WMRequest?
        if _count > 1 {
            request = _movieRequest?.newer
        }else {
            request = _movieRequest
        }
        
        if  request != nil {
            WMovie.performUpcomingMoviesRequest(request: request!) { [weak self] movies in
                DispatchQueue.main.async{
                    self?.insertMovies(movies)
                }
            }
        }
    }
}
