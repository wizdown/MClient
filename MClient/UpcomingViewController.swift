//
//  UpcomingViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData


class UpcomingViewController: NSFRCViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let networkManager : NetworkManager = NetworkManager()
    private var _segueIdentifierForMovieDetails: String?
    
    
//    var container: NSPersistentContainer? =
//        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
////        { didSet{ updateUI() } }
    
    var fetchedResultsController: NSFetchedResultsController<Movie>?
    
    private func setUpNSFRC() {
        
//        if let context = container?.viewContext {
        
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "release_date", ascending: true)]
        
//            let release_date_string = Date().description.components(separatedBy: " ")[0]
//        
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
//        
//            let date = dateFormatter.date(from: release_date_string)
//        
//             let required_date = (NSCalendar.current.date(byAdding: Calendar.Component.day, value: 1, to: date!))
//            print("Required Date : \(required_date)")
        
            
            request.predicate = NSPredicate(format: "release_date > %@", Date() as NSDate)

            fetchedResultsController = NSFetchedResultsController<Movie>(
                fetchRequest: request,
                managedObjectContext: DbManager.readContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            fetchedResultsController?.delegate = self as NSFRCViewController
            
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print(error.localizedDescription)
            }
            collectionView.reloadData()
            
//        }
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _collectionView = collectionView
        
        title = "Upcoming Movies"
        _segueIdentifierForMovieDetails = "UpcomingToMovieDetailSegue"
        
        
        collectionView.register(UINib(nibName: "newMovieCell", bundle: nil), forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        setUpNSFRC()
        
//        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: DbManager.privateContext, queue: nil, using: {
//            notification in
////            print(notification.userInfo)
////            DbManager.mainContext.mergeChanges(fromContextDidSave: notification)
//            try? DbManager.mainContext.save()
//        })
        
        
//        // Adding check here so that it does not fetch movies that are coming in next 180 days in the initial request
//        let max_required_date = (NSCalendar.current.date(byAdding: Calendar.Component.day, value: 180, to: Date() as Date))!
//        if let context = container?.viewContext {
//            let latest_date = Movie.getLatestDate(in: context)
//            if latest_date <= max_required_date {
//                getResults()
//            }
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let latest_date = DbManager.getLatestDate()
        if latest_date <= Date() {
            getResults()
        }
        collectionView?.collectionViewLayout.invalidateLayout()

//        if let context = container?.viewContext{
//            let latest_date = Movie.getLatestDate(in: context)
//            if latest_date <= Date() {
//                getResults()
//            }
//        }
//        collectionView?.collectionViewLayout.invalidateLayout()

    }
    
    private func loadMore() {
        getResults()
        
    }
    
    private func completionHandler(_ movies : [WMovie] ) {
       print("Movies found : \(movies.count)")
    }
    
     private func getResults() {
        networkManager.getUpcomingMovies(afterDate: DbManager.getLatestDate(), completion : completionHandler)

        
//        if let context = container?.viewContext {
//            let date = Movie.getLatestDate(in: context)
//            networkManager.getUpcomingMovies(afterDate: date, completion : completionHandler)
//           
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Item clicked ( \(indexPath.section) , \(indexPath.row) )")
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
        
        if currentDate.timeIntervalSince1970 - _timeSinceLastMovieResultsFetch.timeIntervalSince1970 > _reloadTimeLag ,
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

extension UpcomingViewController : UICollectionViewDelegateFlowLayout {
    
    
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


