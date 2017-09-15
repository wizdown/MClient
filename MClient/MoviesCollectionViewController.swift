//
//  MoviesCollectionViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

fileprivate var itemsPerRow : CGFloat = 2
fileprivate let sectionInsets = UIEdgeInsets(top: 10.0 , left: 10.0 , bottom: 10.0 , right: 10.0 )

class MoviesCollectionViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource  , UIScrollViewDelegate {

    // --------------------------------------------------------------------------------------
    // The following variables and methods may need to be set/defined by the subclass
    
    var _collectionView: UICollectionView?
    var _navigationViewControllerTitle: String?
    var _segueIdentifierForMovieDetails: String?
    var _movieRequest: WMRequest?

    
    func getResults() { // need to override this in subclass
        fatalError("Subclass did not implement getNewMovies()")
        
        //put insertMovies in completion handler for movie request
    }
    
    func initialize() { // need to override this in subclass
        fatalError("Subclass did not implement initalize()")
        
    }
    
    // ---------------------------------------------------------------------------------------
    
    // Following code contains common methods and variables
    
    var _results = [[WMovie]]()
    var _count: Int = 1
    var _previousQueryPending: Bool = false


    
    override func viewDidLoad() {
        super.viewDidLoad()
        _previousQueryPending = false
        _count = 1

        initialize()
        
        _collectionView?.register(UINib(nibName: "newMovieCell", bundle: nil), forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
        title = _navigationViewControllerTitle
        self._collectionView?.delegate = self
        self._collectionView?.dataSource = self
        
        if _movieRequest != nil {
            getResults()
        }
    }
    
    //    private var _timeSinceLastMovieResultsFetch: Date = Date()
    //    private let _reloadTimeLag : Double = 2.0 // seconds
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let currentDate = Date()
//        
//        if _movieRequest != nil ,
//            currentDate.timeIntervalSince1970 - _timeSinceLastMovieResultsFetch.timeIntervalSince1970 > _reloadTimeLag ,
//            scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > 50 {
//            loadMore()
//            _timeSinceLastMovieResultsFetch = currentDate
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if _previousQueryPending == false ,
            scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > 50 {
            loadMore()
        }
    }
    
    private func loadMore() {
        _previousQueryPending = true
        print("Loading More(\(_count))")
        _count = _count + 1
        getResults()
        
    }
    
 
    func insertMovies( _ movies: [WMovie] ) {
        if _results.count == 0 {
            self._results.insert(movies,at : 0) //2
            self._collectionView?.insertSections([0]) // 3
            print("Load ==> Movies Found : \(movies.count)")
            
        }
        else
        {
            if(movies.count > 0) {
                let oldCount = _results[0].count
                self._results[0].append(contentsOf: movies)
                let newCount = _results[0].count
                self._collectionView?.performBatchUpdates({
                    var currentItem = oldCount
                    while currentItem < newCount {
                        self._collectionView?.insertItems(at: [IndexPath(row: currentItem ,section: 0)])
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
            itemsPerRow = 2
        } else {
            itemsPerRow = 3
        }
        _collectionView?.collectionViewLayout.invalidateLayout()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item clicked ( \(indexPath.section) , \(indexPath.row) )")
        performSegue(withIdentifier: _segueIdentifierForMovieDetails!, sender: indexPath )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        print(segue.destination.contents)
        if let movieViewController = segue.destination.contents as? MovieDetailsViewController ,
            let indexPath = sender as? IndexPath {
            movieViewController.movie = _results[indexPath.section][indexPath.row]
            print("Setting Movie for Movie Details")
        }
    }
}

extension MoviesCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    
//    1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem )
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

