//
//  SearchViewController.swift
//  MClient
//
//  Created by gupta.a on 10/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: MoviesCollectionViewController, UICollectionViewDataSource , UISearchBarDelegate {
    
    var _segueIdentifierForMovieDetails: String?
    var _movieRequest: WMRequest?
    
    var _results = [[WMovie]]()
        var _count: Int = 1
        var _previousQueryPending: Bool = false

    @IBOutlet  var collectionView: UICollectionView!
   
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.collectionViewLayout.invalidateLayout()

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text
    }
    
    private var _timeSinceLastMovieResultsFetch: Date = Date()
    private let _reloadTimeLag : Double = 1.0 // seconds
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentDate = Date()

        if _previousQueryPending == false ,
            currentDate.timeIntervalSince1970 - _timeSinceLastMovieResultsFetch.timeIntervalSince1970 > _reloadTimeLag ,
            scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > 50 {
                loadMore()
                _timeSinceLastMovieResultsFetch = currentDate
        }
    }

    private func loadMore() {
        print("Loading More(\(_count))")
        _count = _count + 1
        getResults()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _previousQueryPending = false
        _count = 1

        title = "Search"
        _segueIdentifierForMovieDetails = "SearchToMovieDetailSegue"

        collectionView.register(UINib(nibName: "newMovieCell", bundle: nil), forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
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


      func getResults() {
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
    
        func insertMovies( _ movies: [WMovie] ) {
            if _results.count == 0 {
                self._results.insert(movies,at : 0) //2
                self.collectionView.insertSections([0]) // 3
                print("Load ==> Movies Found : \(movies.count)")
    
            }
            else
            {
                if(movies.count > 0) {
                    let oldCount = _results[0].count
                    self._results[0].append(contentsOf: movies)
                    let newCount = _results[0].count
                    self.collectionView.performBatchUpdates({
                        var currentItem = oldCount
                        while currentItem < newCount {
                            self.collectionView.insertItems(at: [IndexPath(row: currentItem ,section: 0)])
                            currentItem = currentItem + 1
                        }
                    }, completion: { animationDidComplete  in
                        print("\(newCount - oldCount) items added!")
                    })
                }
                print("Reload ==> Movies Found : \(movies.count)")
    
            }
            _previousQueryPending = false
        }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            _items = 2
        } else {
            _items = 3
        }
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return _results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return _results[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.movieCellReuseIdentifier, for: indexPath)
        let movie: WMovie = _results[indexPath.section][indexPath.row]
        // Configure the cell
        if let cell = cell as? newMovieCell {
            cell.movie = movie
        }
        return cell
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        print(segue.destination.contents)
        if let movieViewController = segue.destination.contents as? MovieDetailsViewController ,
            let indexPath = sender as? IndexPath {
            movieViewController.movie = _results[indexPath.section][indexPath.row]
            print("Setting Movie for Movie Details")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item clicked ( \(indexPath.section) , \(indexPath.row) )")
        performSegue(withIdentifier: _segueIdentifierForMovieDetails!, sender: indexPath )
    }
    
   
}

