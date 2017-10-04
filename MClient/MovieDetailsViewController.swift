//
//  MovieDetailsViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

enum WatchlistAction {
    case ADD
    case REMOVE
}

class MovieDetailsViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource , WatchlistDelegate {
    
    private let networkManager = NetworkManager()
    
    var needsPersistence: NeedPersistence = NeedPersistence(isNeeded: false)
    
    
    @IBOutlet weak var movieView: MovieView! {
        didSet{
            movieView.castCollectionView.delegate = self
            movieView.castCollectionView.dataSource = self
            movieView.delegate = self
        }
    }
    
    var movie : WMovie?
    
    private var _cast = [[WCastPeople]]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        if movie != nil {
            setWatchlistButtonProfile()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         movieView.castCollectionView.register(UINib(nibName: "NewCastCell", bundle: nil), forCellWithReuseIdentifier: Constants.castCellReuseIdentifier)
        getCast()
    }

    private func setWatchlistButtonProfile() {
        if let _ = UserDefaults.standard.string(forKey: Constants.key_account_id) ,
            let _ = UserDefaults.standard.string(forKey: Constants.key_session_id),
            let contents = movie
        {
            if DbManager.isMovieAvailableInWatchlist(id: contents.id) {
                movieView.profile = .READY_TO_REMOVE
            } else {
                movieView.profile = .READY_TO_ADD
            }
        }
        else {
            movieView.profile = .DISABLED
        }
    }
    
   
    private func getCast() {
        if let contents = movie {
            movieView.movie = contents
            
            let temp_cast = DbManager.getMovieCast(movieId: contents.id)
            if temp_cast.count > 0 {
                self.insertCast(temp_cast)
            } else {
                print("Getting Cast from Network")
                self.networkManager.getMovieCast(forMovieId : contents.id , completion: self.movieCastCompletionHandler(_:))
            }
        }
    }
    
    // Handler to handle when Movie's cast request returns
    private func movieCastCompletionHandler(_ cast : [WCastPeople]) {
        if cast.count == 0 {
            print("Cast Not Found!")
        } else {
            print("\(cast.count) cast found")
            self.insertCast(cast)
        }
    }
    
    private func insertCast(_ cast: [WCastPeople]){
        self._cast.removeAll()
        self._cast.insert(cast,at : 0) //2
        DispatchQueue.main.async { [ weak self ] in
            self?.movieView.castCollectionView.reloadData()
        }
//        movieView.castCollectionView.insertSections([0])
        print("Load ==> Cast Count Found : \(cast.count)")
        
    }
    
    private func watchlistHandler(success : Bool , movie : WMovie , action : WatchlistAction) {
        var newProfile : WatchListButtonProfile
        if success {
//            self.updateWatchlistInDb(withMovie: movie, action: action)
            // Need to remove it here
            switch action {
                case .ADD : newProfile = .READY_TO_REMOVE
                case .REMOVE : newProfile = .READY_TO_ADD
            }
        } else {
            print("Failed to add movie to watchlist(network failure) ")
            switch action {
                case .ADD : newProfile = .READY_TO_ADD
                case .REMOVE : newProfile = .READY_TO_REMOVE
            }
        }
        
        DispatchQueue.main.async { [ weak self ] in
            self?.movieView.profile = newProfile
        }
    }
    
    // Called when AddToWatchlist is clicked
    func didPerformAddToWatchlist(profile : WatchListButtonProfile) {
        
        if let strongMovie = movie {
            switch profile {
                case .DISABLED : print("Login to use this")
                    showDisabledAlertMessage()
                
                case .READY_TO_ADD : print("Initiating add to watchlist")
                    networkManager.updateWatchlist(withMovie: strongMovie, action: .ADD, completion: watchlistHandler(success:movie:action:))
                
                case .READY_TO_REMOVE : print("Initiating remove from watchlist" )
                  networkManager.updateWatchlist(withMovie: strongMovie, action: .REMOVE, completion: watchlistHandler(success:movie:action:))
            }
        }
    }
    
    private func showDisabledAlertMessage() {
        let alert = UIAlertController(title: "Login Required", message: "Please login to use this feature.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "castDetailSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let castDetailViewController = segue.destination.contents as? CastDetailViewController ,
            let indexPath = sender as? IndexPath {
            castDetailViewController._cast = _cast[indexPath.section][indexPath.row]
            
            var persistence = self.needsPersistence
            persistence.incrStepCount()
            castDetailViewController.needsPersistence = persistence
            
            print("Setting Cast for Cast Details")
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _cast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _cast[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.castCellReuseIdentifier, for: indexPath )
        let cast: WCastPeople = _cast[indexPath.section][indexPath.row]
        if let cell = cell as? NewCastCell {
            cell.cast = cast
        }
        return cell
    }
}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

fileprivate var _items : CGFloat = 1
fileprivate var _sectionInsets = UIEdgeInsets(top: 5.0 , left: 5.0 , bottom: 5.0 , right: 5.0 )

extension MovieDetailsViewController : UICollectionViewDelegateFlowLayout {
    
     func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = _sectionInsets.left * ( _items + 1 )
        let availableHeight = collectionView.frame.height - paddingSpace
        let HeightPerItem = availableHeight / _items
        return CGSize(width: HeightPerItem, height: HeightPerItem )
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return _sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return _sectionInsets.left
    }
}

