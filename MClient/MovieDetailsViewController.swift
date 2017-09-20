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

fileprivate var itemsPerColumn : CGFloat = 1
fileprivate let sectionInsets = UIEdgeInsets(top: 5.0 , left: 5.0 , bottom: 5.0 , right: 5.0 )

class MovieDetailsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , WatchlistDelegate {
    
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieView.castCollectionView.register(UINib(nibName: "NewCastCell", bundle: nil), forCellWithReuseIdentifier: Constants.castCellReuseIdentifier)
        getData()
    }
    
    private func setWatchlistButtonInitialProfile() {
        if let _ = UserDefaults.standard.string(forKey: Constants.key_account_id) ,
            let _ = UserDefaults.standard.string(forKey: Constants.key_session_id),
            let contents = movie
            {
                if let context = container?.viewContext,
                    let db_movie = try? Movie.findOrCreateMovie(matching: contents, in: context) {
                    if db_movie.isInWatchlist {
                        movieView.profile = .READY_TO_REMOVE
                    } else {
                        movieView.profile = .READY_TO_ADD
                    }
                } else {
                    movieView.profile = .DISABLED
                }
            }
        else {
            movieView.profile = .DISABLED
        }
    }
    
    private func getData() {
        if let contents = movie {
            setWatchlistButtonInitialProfile()
            movieView.movie = contents
            container?.performBackgroundTask{ [weak self] context in
                if let db_movie = try? Movie.findOrCreateMovie(matching: contents, in: context) {
                    if (self?.needsPersistence.required)! {  // Why did xcode force me to unwrap this ?
                        try? context.save()
                        print("Attempting to save Movie to DB")
                    }
                    if let db_cast = db_movie.cast,
                        db_cast.count > 0 {
                        self?.displayCastUsingDb(forDbMovie: db_movie, context: context)
                    } else {
                        self?.getAndDisplayCastFromNetwork(forDbMovie: db_movie, context: context)

                    }
                }
            }
        }
    }
    
    private func getAndDisplayCastFromNetwork(forDbMovie db_movie : Movie , context: NSManagedObjectContext ) {
        
        print("Getting Cast from Network")
        if let request = WMRequest.castForMovieRequest(movieId: Int(db_movie.id)) {
            
            WMRequest.performGetCastForAMovieRequest(request: request) {  [weak self]
                (cast: [WCastPeople]) in
                if cast.count == 0 {
                    print("Couldn't fetch cast from network")
                    self?.displayCastUsingDb(forDbMovie: db_movie, context: context)
                } else {
                    print("\(cast.count) cast found")
                    DispatchQueue.main.async { [weak self] in
                        self?.insertCast(cast)
                        self?.saveCastToDb(cast: cast, forMovie: WMovie(credit:db_movie) ,  context: context)
                    }
                }
            }
        }
        
    }
    
    private func saveCastToDb(cast : [WCastPeople] ,forMovie movie : WMovie, context: NSManagedObjectContext){
        if needsPersistence.required {
            print("Saving Cast to DB")
            context.perform {
                _ = try? Movie.findOrCreateCast(matching: movie, cast: cast, in: context)
                try? context.save()
                
            }
        }
    }
    
    private func displayCastUsingDb(forDbMovie db_movie: Movie, context: NSManagedObjectContext) {
        context.perform {
            print("Displaying Cast from DB")
            if let db_cast = db_movie.cast?.sortedArray(using:[NSSortDescriptor(key: "id", ascending: true)]) as? [Person] {
                var temp_cast = [WCastPeople]()
                for current_person in db_cast {
                    temp_cast.append(WCastPeople(person: current_person))
                }
                DispatchQueue.main.async { [weak self ] in
                    self?.insertCast(temp_cast)
                }
            }
        }
        
    }
    
    private func updateCastInDB(_ cast : [WCastPeople]) {
        container?.performBackgroundTask { context in
            print("Saving Cast to DB")
            _ = try? Movie.findOrCreateCast(matching: self.movie!, cast: cast, in: context)
//            print(db_movie?.cast!)
            do {
                try context.save()
                print("Cast and Movie Saved")
            }catch {
                print(error.localizedDescription)
//                throw error
            }
        }
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
    
    private func insertCast(_ cast: [WCastPeople]) {
        self._cast.removeAll()
        self._cast.insert(cast,at : 0) //2
        movieView.castCollectionView.reloadData()
//        movieView.castCollectionView.insertSections([0])
        print("Load ==> Cast Count Found : \(cast.count)")
        
    }
    
    private func getResults(){
        print("Getting Cast results from network")
        if let id = movie?.id {
            let request = WMRequest.castForMovieRequest(movieId: id)
            if request != nil {
                WMRequest.performGetCastForAMovieRequest(request: request!) {
                    [weak self]
                    (cast: [WCastPeople]) in
                    DispatchQueue.main.async { [weak self] in
                        self?.insertCast(cast)
                        self?.updateCastInDB(cast)  // This call be removed from main thread // Do it later
                    }
                }
            }
        } else {
            print("CastCollectionView: Unable to fetch data")
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
    
    private func updateWatchlistInDb(withMovie movie : WMovie , action: WatchlistAction , newProfile : WatchListButtonProfile  ){
            container?.performBackgroundTask{ context in
                let _ = Movie.updateWatchlistInDb(with: movie, action: action, in: context)
                do {
                    try context.save()
                }catch {
                    print("Error while adding movie to watchlist in DB")
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async { [ weak self ] in
                    self?.movieView.profile = newProfile
                }
            }
        
    }
    
    // Called when AddToWatchlist is clicked
    func didPerformAddToWatchlist(profile : WatchListButtonProfile) {
        
//        // This setting of default values needs to be removed from here
//        let session_id  = UserDefaults.standard.string(forKey: "sessionId")
//        if session_id == nil {
//            UserDefaults.standard.set("749e8798cc8f35181efb7048b3626328e5f8bee5", forKey: "sessionId")
//        }
//        
//        let account_id  = UserDefaults.standard.string(forKey: "accountId")
//        if account_id == nil {
//            UserDefaults.standard.set("6653343", forKey: "accountId")
//        }
        
        if let strongMovie = movie {
            switch profile {
                case .DISABLED : print("Login to use this")
                // Add some prompt to show error
                
                case .READY_TO_ADD : print("Initiating add to watchlist")
                    if let request = WMRequest.getUpdateWatchlistRequest() {
                            request.updateWatchlist(with: strongMovie, status: .ADD) {
                                success in
                                if success {
                                    self.updateWatchlistInDb(withMovie: strongMovie, action: .ADD, newProfile: .READY_TO_REMOVE)
                                } else {
                                    print("Failed to add movie to watchlist(network failure) ")
                                }
                        }
                }
                
                case .READY_TO_REMOVE : print("Initiating remove from watchlist" )
                    if let request = WMRequest.getUpdateWatchlistRequest() {
                            request.updateWatchlist(with: strongMovie, status: .REMOVE) {
                                success in
                                if success {
                                    self.updateWatchlistInDb(withMovie: strongMovie , action: .REMOVE, newProfile: .READY_TO_ADD)
                                } else {
                                    print("Failed to remove movie from watchlist(network failure) ")
                                }
                    }
                }
            }
        }
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

extension MovieDetailsViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerColumn + 1)
        let availableHeight = movieView.castCollectionView.frame.height - paddingSpace
        let HeightPerItem = availableHeight / itemsPerColumn
        
        return CGSize(width: HeightPerItem, height: HeightPerItem )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
   
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }
}
