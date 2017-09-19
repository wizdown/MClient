//
//  SearchViewController.swift
//  MClient
//
//  Created by gupta.a on 10/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

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
            _count = 1
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
    
//    private func showResultsFromDb(sarchString: String) -> [WMovie] {
//        var search_results = [WMovie]()
//        if let context = container?.viewContext {
//            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
//            request.predicate = NSPredicate(format: "any title contains[c] %@", sarchString )
//            request.sortDescriptors = [NSSortDescriptor(key:"popularity", ascending: false)]
//            
//            do {
//                let matches = try context.fetch(request)
//                print("SearchViewController.showResultsFromDb ==> Found \(matches.count) results from DB")
//                for current_match in matches {
//                    let current_movie = WMovie(credit: current_match)
//                    search_results.append(current_movie)
//                }
//            } catch {
//                print("SearchViewController.showResultsFromDb ==> Error : \(error.localizedDescription)")
//            }
//        }
//        return search_results
//    }


    override  func getResults() {
        if _previousQueryPending == false {
            _previousQueryPending = true
            
            let request: WMRequest? = _movieRequest ?? WMRequest.movieSearchRequest(forMovie: searchText!)
            
            if  request != nil {
                _movieRequest = request
                
                request?.performRequest() { [weak self]
                    (movies: [WMovie]) in
                    
                    if request == self?._movieRequest {
                        if movies.count == 0 {
                            self?.didSearchReturnNoResults = true
                        }
                        DispatchQueue.main.async{
                            if request == self?._movieRequest {
                                self?.insertMovies(movies)
                            }
                        }
                    }
                    else {
                        self?._previousQueryPending = false
                    }
                }
            }
            else {
                _previousQueryPending = false
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
