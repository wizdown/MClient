//
//  SearchViewController.swift
//  MClient
//
//  Created by gupta.a on 10/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class SearchViewController: MoviesCollectionViewController, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
   
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    private var didSearchReturnNoResults: Bool = false
    
    private var searchText: String? {
        didSet {
            _previousQueryPending = false
            searchBar.resignFirstResponder()
            _results.removeAll()
            _movieRequest = nil
            didSearchReturnNoResults = false
            getResults()
            collectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text
    }
    
    override func initialize() {
        _collectionView = collectionView
        _navigationViewControllerTitle = "Search"
        _segueIdentifierForMovieDetails = "SearchToMovieDetailSegue"
    }

    
    override  func getResults() {
        if _previousQueryPending == false {
            _previousQueryPending = true
            var request: WMRequest?
            if _movieRequest == nil {
                request = WMRequest.movieSearchRequest(forMovie: searchText!)
            } else {
                request = _movieRequest
            }
            if  request != nil {
                _movieRequest = request
                
                request?.performRequest() { [weak self] movies in
                    if movies.count == 0 {
                        self?.didSearchReturnNoResults = true
                    }
                    DispatchQueue.main.async{
                        if request == self?._movieRequest {
                            self?.insertMovies(movies)
                        }
                    }
                }
            }
        }
       
    }
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.searchHeaderReuseIdentifier, for: indexPath)
        if let cell = cell as? SearchHeaderCell {
            if didSearchReturnNoResults {
                cell.message = "No Results Found"
            } else {
                cell.message = "Search Results"
            }
            
        }
        return cell
    }
    
}
