//
//  SearchCollectionViewController.swift
//  MClient
//
//  Created by gupta.a on 29/08/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

private let reuseIdentifier = "movieCell"
private let reuseSupplimentaryViewIdentifier = "searchHeader"

fileprivate var itemsPerRow: CGFloat = 2
fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)


class SearchCollectionViewController: UICollectionViewController , UITextFieldDelegate  {
    
//    var refreshControl: UIRefreshControl!

    var searchResults = [[WMovie]]()
    
    private var didSearchReturnNoResults : Bool = false
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
//    private var previousSearchString: String?
    
    private var lastMovieSearchRequest: WMRequest?
    
    var searchText: String? {
        didSet{
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            searchResults.removeAll()
            lastMovieSearchRequest = nil
            didSearchReturnNoResults = false
            searchForMovie()
            collectionView?.reloadData() //1
        }
    }
    
    private var timeSinceLastMovieResultsFetch : Date = Date()
    private let reloadTimeLag : Double = 2.0 // seconds
    

     override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentDate = Date()
        
        if lastMovieSearchRequest != nil ,
            currentDate.timeIntervalSince1970 - timeSinceLastMovieResultsFetch.timeIntervalSince1970 > reloadTimeLag ,
            scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > 50 {
            loadMore()
            timeSinceLastMovieResultsFetch = currentDate
        }
    }
    
    private var count = 1
    private func loadMore(){
        print("Loading More(\(count))")
        count = count + 1
        searchForMovie()
       
    }
    
    
    private func insertMovies( matchingMovies movies: [WMovie] ) {
        if searchResults.count == 0 {
            if movies.count == 0 {
                didSearchReturnNoResults = true
            }
            self.searchResults.insert(movies,at : 0) //2
            self.collectionView?.insertSections([0]) // 3
            print("Load ==> Movies Found : \(movies.count)")

        }
        else
        {
            if(movies.count > 0) {
                let oldCount = searchResults[0].count
                self.searchResults[0].append(contentsOf: movies)
                let newCount = searchResults[0].count
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
    
    
    
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }

    private func searchForMovie(){
        var request: WMRequest?
        if lastMovieSearchRequest != nil {
            request = lastMovieSearchRequest!.newer
        }
        else {
            request = WMRequest.movieSearchRequest(forMovie: searchText!)

        }

        if  request != nil {
            lastMovieSearchRequest = request
            
            WMovie.performMovieSearchRequest(request: request!) { [weak self] movies in
                DispatchQueue.main.async{
                    if request == self?.lastMovieSearchRequest {
                        self?.insertMovies(matchingMovies: movies)
                    }
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item clicked ( \(indexPath.section) , \(indexPath.row) )")
        performSegue(withIdentifier: "movieDetailSegue", sender: nil )
    }
    
    override func viewWillAppear(_ animated: Bool) {
            searchResults.removeAll()
            self.collectionView?.reloadData()
            searchTextField.text = ""
            searchTextField?.resignFirstResponder()

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "newMovieCell", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return searchResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return searchResults[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//        print("row : \(indexPath.row)")
        let movie: WMovie = searchResults[indexPath.section][indexPath.row]
        // Configure the cell
        if let cell = cell as? newMovieCell {
            cell.movie = movie
//            cell.title.text = "Hoila"
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseSupplimentaryViewIdentifier, for: indexPath)
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

extension SearchCollectionViewController : UICollectionViewDelegateFlowLayout {

    
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
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
