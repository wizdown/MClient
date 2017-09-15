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
            request.predicate = NSPredicate(format: "release_date <= %@", Date() as NSDate)
            
            fetchedResultsController = NSFetchedResultsController<Movie>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            fetchedResultsController?.delegate = self
            
            do {
                try fetchedResultsController?.performFetch()
                print("Fetch request success")
            } catch {
                print(error.localizedDescription)
            }
            _collectionView?.reloadData()
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
            print("Setting Movie for Movie Details")
        }
    }
    
    private func updateDb(movies: [WMovie]) {
        if let context = container?.viewContext , movies.count > 0 {
            if _movieRequest?.lastSuccessfulRequestNumber == 1 {
                let request: NSFetchRequest<Movie> = Movie.fetchRequest()
                request.predicate = NSPredicate(format: "release_date <= %@", Date() as NSDate)
                do {
                    let matches = try context.fetch(request)
                    if matches.count > 0 {
                        for current_match in matches {
                            context.delete(current_match)
                            try context.save()
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            for current_movie in movies {
                _ = try? Movie.findOrCreateMovie(matching: current_movie, in: context)
                try? context.save()
            }
        }
        _previousQueryPending = false
    }

    
    override func getResults() {
        _movieRequest?.performRequest() { [weak self]
            (movies: [WMovie]) in
            DispatchQueue.main.async{
                self?.updateDb(movies: movies)
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
