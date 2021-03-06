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
    
    var privateContext : NSManagedObjectContext =
        (UIApplication.shared.delegate as! AppDelegate).pContext
    
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
        
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: privateContext, queue: nil, using: {
                notification in
//                  print(notification.userInfo ?? "")
                self.container?.viewContext.mergeChanges(fromContextDidSave: notification)
        })
        getData()
        
    }

    private func setWatchlistButtonInitialProfile() {
        
        if let _ = UserDefaults.standard.string(forKey: Constants.key_account_id) ,
            let _ = UserDefaults.standard.string(forKey: Constants.key_session_id),
            let contents = movie
        {
            if let context = container?.viewContext {
                if let db_movie = Movie.find(matching: contents, in: context) {
                        if db_movie.isInWatchlist {
                        DispatchQueue.main.async { [weak self] in
                            self?.movieView.profile = .READY_TO_REMOVE
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            self?.movieView.profile = .READY_TO_ADD
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.movieView.profile = .READY_TO_ADD
                    }
                }
            } else {
                movieView.profile = .DISABLED
            }
        }
        else {
            movieView.profile = .DISABLED
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if movie != nil {
            setWatchlistButtonInitialProfile()
        }
    }
    
    private func getData() {
        if let contents = movie {
//            setWatchlistButtonInitialProfile()
            movieView.movie = contents
            
            if let context = container?.viewContext,
                let db_movie = Movie.find(matching: contents, in: context) {
//                    if needsPersistence.required {
//                        privateContext.performAndWait {
//                            let _ = Movie.create(using: contents, in: self.privateContext)
//                            try? context.save()
//                            print("Attempting to save Movie to DB")
//                        }
//                    }
                    if let db_cast = db_movie.cast,
                        db_cast.count > 0 {
                        displayCastUsingDb()
                    } else {
                        getAndDisplayCastFromNetwork()
                        
                    }
            } else {
                getAndDisplayCastFromNetwork()
            }

            
        }
    }
    
    private func getAndDisplayCastFromNetwork() {
        
        print("Getting Cast from Network")
        if let contents = movie ,
            let request = WMRequest.castForMovieRequest(movieId: Int(contents.id)) {
            
            WMRequest.performGetCastForAMovieRequest(request: request) {  [weak self]
                (cast: [WCastPeople]) in
                if cast.count == 0 {
                    print("Couldn't fetch cast from network")
//                    self?.displayCastUsingDb(forDbMovie: db_movie, context: context)
                } else {
                    print("\(cast.count) cast found")
                    self?.saveCastToDb(cast: cast, forMovie: contents)
                    DispatchQueue.main.async { [weak self] in
                        self?.insertCast(cast)
                    }
                }
            }
        }
        
    }
    
    private func saveCastToDb(cast : [WCastPeople] ,forMovie movie : WMovie){
        if needsPersistence.required {
            privateContext.performAndWait {
                print("Saving Cast to DB")
                let db_movie = try? Movie.addCast(for : movie , cast : cast, in: self.privateContext)
                if db_movie != nil {
                    try? self.privateContext.save()
                }
            }
           
        }
    }
    
    private func displayCastUsingDb() {
        if let context = container?.viewContext ,
            let contents = movie {
            print("Displaying Cast from DB")
            if let db_movie = Movie.find(matching: contents, in: context) ,
                let db_cast = db_movie.cast?.sortedArray(using:[NSSortDescriptor(key: "id", ascending: true)]) as? [Person]
            {
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
        if let contents = movie{
            let request = WMRequest.castForMovieRequest(movieId: contents.id)
            if request != nil {
                WMRequest.performGetCastForAMovieRequest(request: request!) {
                    (cast: [WCastPeople]) in
                    DispatchQueue.main.async { [weak self] in
                        self?.insertCast(cast)
                    }
                    self.saveCastToDb(cast: cast, forMovie: contents) // This call be removed from main thread // Do it later
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
    
    private func updateWatchlistInDb(withMovie movie : WMovie , action: WatchlistAction , newProfile : WatchListButtonProfile ) {
        privateContext.performAndWait {
            let _ = Movie.updateWatchlistInDb(with: movie, action: action, in: self.privateContext)
            do {
                try self.privateContext.save()
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
        
        if let strongMovie = movie {
            switch profile {
                case .DISABLED : print("Login to use this")
                // Add some prompt to show error
                
                let alert = UIAlertController(title: "Login Required", message: "Please login to use this feature.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                case .READY_TO_ADD : print("Initiating add to watchlist")
                    if let request = WMRequest.getUpdateWatchlistRequest() {
                            request.updateWatchlist(with: strongMovie, status: .ADD) {
                                success in
                                if success {
                                    self.updateWatchlistInDb(withMovie: strongMovie, action: .ADD, newProfile: .READY_TO_REMOVE)
                                } else {
                                      print("Failed to add movie to watchlist(network failure) ")
                                    DispatchQueue.main.async { [ weak self ] in
                                        self?.movieView.profile = profile
                                    }
                                  
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
                                    DispatchQueue.main.async { [ weak self ] in
                                        self?.movieView.profile = profile
                                    }
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

