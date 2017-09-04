//
//  SearchCollectionViewController.swift
//  MClient
//
//  Created by gupta.a on 29/08/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

private let reuseIdentifier = "searchMovieItem"

fileprivate var itemsPerRow: CGFloat = 2
fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)


class SearchCollectionViewController: UICollectionViewController , UITextFieldDelegate {
    
//    var refreshControl: UIRefreshControl!

    private var searchResults = [[WMovie]]()
    
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
            searchForMovie()
//            collectionView?.reloadData()

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
    
    private func insertMovies( matchingMovies movies: [WMovie] ) {
        self.searchResults.append(movies)
        self.collectionView?.reloadData()
        print("Movies Found : \(movies.count)")
    }
//
//    private func insertMovies( matchingMovies movies: [WMovie] ) {
//        if self.searchResults.count == 0 {
//            self.searchResults.append([WMovie]())
//        }
//        for movie in movies {
//            self.searchResults[0].append(movie)
//            self.collectionView?.insertItems(at: [IndexPath(row: searchResults[0].count-1, section: 0 )])
//
//        }
//
////        self.searchResults.append(movies)
////        self.collectionView?.reloadData()
//        print("Movies Found : \(movies.count)")
//    }
    
    private func searchForMovie(){
//        let name: String = searchText!
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
    
//    private func loadMore(){
//        print("Loading More")
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if searchResults.count > 0{
//            if indexPath.row == searchResults[0].count - 1 {
//                self.loadMore()
//            }
//        }
//        
//    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.refreshControl = UIRefreshControl()
//        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
//        collectionView!.addSubview(refreshControl)
//        
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
//        WRequest.performMovieSearchRequest(forMovie: "game", page: 1)
       
    }
//    
//    func refresh ( sender: AnyObject) {
//        print("Refresh karo")
//        self.refreshControl?.endRefreshing()
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

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
        let movie: WMovie = searchResults[indexPath.section][indexPath.row]
        // Configure the cell
        if let cell = cell as? SearchCollectionViewCell {
            cell.movie = movie
//            cell.title.text = "Hoila"
        }
        return cell
    }
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("Displaying cell : \(indexPath.row)")
//    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

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
