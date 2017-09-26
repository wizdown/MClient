//
//  NowPlayingViewController.swift
//  MClient
//
//  Created by gupta.a on 05/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData



// UIScrollViewDelegate and UICollectionViewDelegate are inherited from the superclass.
class NowPlayingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource    {
    
    var cleanupRequired : Bool = true
    private let networkManager = NetworkManager()
    private var _segueIdentifierForMovieDetails: String?

    @IBOutlet weak var collectionView: UICollectionView!
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<Movie>?
    
    private func setUpNSFRC() {
        if let context = container?.viewContext {
            
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
            request.predicate = NSPredicate(format: "isPlaying = %@", true as CVarArg)
            
            fetchedResultsController = NSFetchedResultsController<Movie>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            fetchedResultsController?.delegate = self
            
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print(error.localizedDescription)
            }
            collectionView.reloadData()
        }
    }
    
    private func completionHandler(_ movies : [WMovie]) {
        DispatchQueue.main.async{
            if movies.count > 0 {
                self.updateDb(movies: movies)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getResults(.INITIAL)
        collectionView?.collectionViewLayout.invalidateLayout()

    }
    
     private func loadMore() {
        getResults(.MORE)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Now Playing"
        _segueIdentifierForMovieDetails = "NowPlayingToMovieDetailSegue"
        
        
        collectionView.register(UINib(nibName: "newMovieCell", bundle: nil), forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        setUpNSFRC()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        print(segue.destination.contents)
        if let movieViewController = segue.destination.contents as? MovieDetailsViewController ,
            let indexPath = sender as? IndexPath ,
            let contents = fetchedResultsController?.object(at: indexPath) {
            movieViewController.movie = WMovie(credit: contents)
            
            var persistence = NeedPersistence(isNeeded: true)
            persistence.incrStepCount()
           
            movieViewController.needsPersistence = persistence
            print("Setting Movie for Movie Details")
        }
    }
    
    private func doNetworkQueryResults(_ movies: [WMovie], contain db_movie : Movie) -> Bool {
        for current_movie in movies {
            if current_movie.id == Int(db_movie.id) {
                return true
            }
        }
        return false
    }
    
    private func updateOldMovies(except movies : [WMovie]) {
        // Deletes or retains old movies as needed
        if let context = container?.viewContext {
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            let release_date_predicate =  NSPredicate(format: "release_date <= %@", Date() as NSDate)
            let not_in_watchlist_predicate = NSPredicate(format: "isInWatchlist = %@", false as CVarArg)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [release_date_predicate, not_in_watchlist_predicate])
            // ADd predicate
            do {
                var delete_count : Int = 0
                let matches = try context.fetch(request)
                if matches.count > 0 {
                    for current_match in matches {
                        if !doNetworkQueryResults(movies, contain: current_match) {
                                context.delete(current_match)
                                try context.save()
                                delete_count = delete_count + 1
                        }
                    }
                }
                print("Removed \(delete_count) old movies")
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func deleteOldCast() {
        // Deleting Casts with no movie Credits Left
        
        container?.performBackgroundTask{ background_context in
            let cast_request : NSFetchRequest<Person> = Person.fetchRequest()
            cast_request.predicate = NSPredicate(format: "movieCredits.@count == 0 " )  // Issue here
            do {
                let matches = try background_context.fetch(cast_request)
                if matches.count > 0 {
                    for current_match in matches {
                        background_context.delete(current_match)
                    }
                    try background_context.save()
                    print("Deleted \(matches.count) People with no movieCredits")
                }
            }
            catch {
                print("Error in removing cast with no MovieCredits")
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateDb(movies: [WMovie]) {
        if let context = self.container?.viewContext , movies.count > 0 {
            if self.cleanupRequired {
                self.cleanupRequired = false
                self.updateOldMovies(except: movies)
                self.deleteOldCast()
            }
            
            for current_movie in movies {
                let db_movie = try? Movie.findOrCreateMovie(matching: current_movie, in: context)
                db_movie?.isPlaying = true
                try? context.save()
            }
        }
//        self._previousQueryPending = false
    }

    func getResults(_ action : RequestAction ) {
        networkManager.getNowPlayingMovies(action: action, completion: completionHandler)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item clicked ( \(indexPath.section) , \(indexPath.row) )")
        performSegue(withIdentifier: _segueIdentifierForMovieDetails!, sender: indexPath )
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
    
    private var _timeSinceLastMovieResultsFetch: Date = Date()
    private let _reloadTimeLag : Double = 1.0 // seconds
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentDate = Date()
        
          if  currentDate.timeIntervalSince1970 - _timeSinceLastMovieResultsFetch.timeIntervalSince1970 > _reloadTimeLag ,
            scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height > 50 {
            loadMore()
            _timeSinceLastMovieResultsFetch = currentDate
        }
    }
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController?.sections?.count ?? 1
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.movieCellReuseIdentifier, for: indexPath)
        
        if let movie = fetchedResultsController?.object(at: indexPath) ,
            let cell = cell as? newMovieCell
        {
            cell.movie = WMovie(credit: movie)
        }
        return cell
    }
}


fileprivate var _items : CGFloat = 2
fileprivate var _sectionInsets = UIEdgeInsets(top: 10.0 , left: 10.0 , bottom: 10.0 , right: 10.0 )

extension NowPlayingViewController : UICollectionViewDelegateFlowLayout {
    
    
    //    1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = _sectionInsets.left * (_items + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / _items
        return CGSize(width: widthPerItem, height: widthPerItem )
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


