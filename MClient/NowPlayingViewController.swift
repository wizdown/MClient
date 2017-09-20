//
//  NowPlayingViewController.swift
//  MClient
//
//  Created by gupta.a on 05/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

fileprivate var itemsPerRow: CGFloat = 2
fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

class NowPlayingViewController:MoviesCollectionViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<Movie>?
    
    private func updateUI() {
        if let context = container?.viewContext {
            
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
//            request.predicate = NSPredicate(format: "release_date <= %@", Date() as NSDate)
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
//                print("Fetch request success")
            } catch {
                print(error.localizedDescription)
            }
            _collectionView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        print("Now Playing will appear")
        if _movieRequest?.lastSuccessfulRequestNumber == 0 {
            getResults()
        }
    }
    
    override func showData() {
        updateUI()
        getResults()
    }

    
    override func initialize() {
        _collectionView = collectionView
        _navigationViewControllerTitle = "Now Playing"
        _segueIdentifierForMovieDetails = "NowPlayingToMovieDetailSegue"
        _movieRequest = WMRequest.nowPlayingMoviesRequest()
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
        if let context = container?.viewContext , movies.count > 0 {
            if _movieRequest?.lastSuccessfulRequestNumber == 1 {
                
                updateOldMovies(except: movies)
                deleteOldCast()
                
            }
            
            for current_movie in movies {
                let db_movie = try? Movie.findOrCreateMovie(matching: current_movie, in: context)
                db_movie?.isPlaying = true
                try? context.save()
            }
        }
        _previousQueryPending = false
    }

    
    override func getResults() {
        if _previousQueryPending == false {
            _previousQueryPending = true
            if let request = _movieRequest {
                request.performRequest() { [weak self]
                    (movies: [WMovie]) in
                    DispatchQueue.main.async{
                        self?.updateDb(movies: movies)
                    }
                }

            } else {
                _previousQueryPending = false
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.movieCellReuseIdentifier, for: indexPath)
        
        if let movie = fetchedResultsController?.object(at: indexPath) ,
            let cell = cell as? newMovieCell
        {
            cell.movie = WMovie(credit: movie)
        }
        return cell
    }

    
}
