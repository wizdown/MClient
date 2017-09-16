//
//  UpcomingViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

fileprivate var itemsPerRow : CGFloat = 2
fileprivate let sectionInsets = UIEdgeInsets(top: 10.0 , left: 10.0 , bottom: 10.0 , right: 10.0 )

class UpcomingViewController: MoviesCollectionViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
//        { didSet{ updateUI() } }
    
    var fetchedResultsController: NSFetchedResultsController<Movie>?
    
    
    private func updateUI() {
        if let context = container?.viewContext {
            
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "release_date", ascending: true)]
            request.predicate = NSPredicate(format: "release_date > %@", Date() as NSDate)
            
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
            _collectionView?.reloadData()
        }
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

    override func showData() {
        updateUI()

        // Adding check here so that it does not fetch movies that are coming in next 180 days in the initial request
        let max_required_date = (NSCalendar.current.date(byAdding: Calendar.Component.day, value: 180, to: Date() as Date))!
        if let context = container?.viewContext {
            let latest_date = Movie.getLatestDate(in: context)
            if latest_date <= max_required_date {
                getResults()
            }
        }
    }
    
    override func initialize() {
        _collectionView = collectionView
        _navigationViewControllerTitle = "Upcoming Movies"
        _segueIdentifierForMovieDetails = "UpcomingToMovieDetailSegue"
    }
    
    private func updateDb(_ movies: [WMovie]) {
        if let context = container?.viewContext {
                for current_movie in movies {
                _ = try? Movie.findOrCreateMovie(matching: current_movie, in: context)
                try? context.save()
                }
            
        }
        _previousQueryPending = false
        
    }
    
    override func getResults() {
        if let context = container?.viewContext {
            let date = Movie.getLatestDate(in: context)
            let request = WMRequest.upcomingMoviesRequest(forDateAfterThis: date)
            request?.performRequest(completion: { [weak self ]
                (movies : [WMovie]) in
                DispatchQueue.main.async {
                    self?.updateDb(movies)
                }
            })
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


