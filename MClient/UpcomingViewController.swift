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

class UpcomingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  , UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var upcomingMovies = [[WMovie]]()
    private var count: Int = 1
    private var previousQueryPending: Bool = false


    private var upcomingMoviesRequest :WMRequest? {
        didSet{
            getUpcomingMovies()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        previousQueryPending = false
        //        self.collectionView.setCollectionViewLayout(self, animated: true)
        
        let nib = UINib(nibName: "newMovieCell", bundle: nil )
        collectionView.register(nib, forCellWithReuseIdentifier: Constants.cellResuseIdentifier )
        
        title = "Upcoming"
        upcomingMoviesRequest = WMRequest.upcomingMoviesRequest()
        count = 1
    }
    
    private var timeSinceLastMovieResultsFetch : Date = Date()
    private let reloadTimeLag : Double = 2.0 // seconds
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentDate = Date()
        
        if upcomingMoviesRequest != nil ,
            currentDate.timeIntervalSince1970 - timeSinceLastMovieResultsFetch.timeIntervalSince1970 > reloadTimeLag ,
            scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > 50 {
            loadMore()
            timeSinceLastMovieResultsFetch = currentDate
        }
    }
    
    private func loadMore(){
        if previousQueryPending == false {
            previousQueryPending = true
            print("Loading More(\(count))")
            count = count + 1
            getUpcomingMovies()
        }
        
    }
    
    private func getUpcomingMovies() {
        var request: WMRequest?
        if count > 1 {
            request = upcomingMoviesRequest?.newer
        }else {
            request = upcomingMoviesRequest
        }
        
        if  request != nil {
            WMovie.performUpcomingMoviesRequest(request: request!) { [weak self] movies in
                DispatchQueue.main.async{
                    self?.insertMovies(movies)
                }
            }
        }
    }

    private func insertMovies( _ movies: [WMovie] ) {
        if upcomingMovies.count == 0 {
            self.upcomingMovies.insert(movies,at : 0) //2
            self.collectionView?.insertSections([0]) // 3
            print("Load ==> Movies Found : \(movies.count)")
            
        }
        else
        {
            if(movies.count > 0) {
                let oldCount = upcomingMovies[0].count
                self.upcomingMovies[0].append(contentsOf: movies)
                let newCount = upcomingMovies[0].count
                self.collectionView?.performBatchUpdates({
                    var currentItem = oldCount
                    while currentItem < newCount {
                        self.collectionView?.insertItems(at: [IndexPath(row: currentItem ,section: 0)])
                        currentItem = currentItem + 1
                    }
                }, completion: { animationDidComplete  in
                    print("New items added!")
                })
            }
            print("Reload ==> Movies Found : \(movies.count)")
            
        }
        previousQueryPending = false
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            itemsPerRow = 2
        } else {
            itemsPerRow = 3
        }
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return upcomingMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return upcomingMovies[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellResuseIdentifier, for: indexPath)
        let movie: WMovie = upcomingMovies[indexPath.section][indexPath.row]
        // Configure the cell
        if let cell = cell as? newMovieCell {
            cell.movie = movie
            //            cell.title.text = "Hoila"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item clicked ( \(indexPath.section) , \(indexPath.row) )")
        performSegue(withIdentifier: "UpcomingToMovieDetailSegue", sender: indexPath )
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print(segue.destination.contents)
        if let movieViewController = segue.destination.contents as? MovieDetailsViewController ,
            let indexPath = sender as? IndexPath {
            movieViewController.movie = upcomingMovies[indexPath.section][indexPath.row]
            print("Setting movie")
        }
    }
    

    
}

extension UpcomingViewController : UICollectionViewDelegateFlowLayout {
    
    
    //1
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
