//
//  WatchlistViewController.swift
//  MClient
//
//  Created by gupta.a on 20/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData


class WatchlistViewController: NSFRCViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    private let networkManager = NetworkManager()
    
    var fetchedResultsController: NSFetchedResultsController<Movie>?
    
    private func updateUserDataInUI() {
        
        var welcomeMessage = ""
        let username = UserDefaults.standard.string(forKey: Constants.key_username)
        if username != nil {
            welcomeMessage.append("\(username!)'s ")
        }
        welcomeMessage.append("watchlist")
        welcomeLabel.text = welcomeMessage
    }
    
    private func setUpNSFRC() {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "isInWatchlist = %@", true as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key : "timestamp" , ascending: true )]
        fetchedResultsController = NSFetchedResultsController<Movie>(
            fetchRequest: request,
            managedObjectContext: DbManager.readContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self as NSFRCViewController
        
        do {
            try fetchedResultsController?.performFetch()
            //                print("Fetch request success")
        } catch {
            print(error.localizedDescription)
        }
        collectionView.reloadData()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _collectionView = collectionView
        
        updateUserDataInUI()
         collectionView.register(UINib(nibName: "newMovieCell", bundle: nil), forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        setUpNSFRC()

        
//        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: DbManager.privateContext, queue: nil, using: {
//            notification in
//            try? DbManager.mainContext.save()
//        })
        networkManager.synchronizeWatchlist()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Item clicked ( \(indexPath.section) , \(indexPath.row) )")
        performSegue(withIdentifier: "watchlistToMovieSegue", sender: indexPath )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        print(segue.destination.contents)
        if let movieViewController = segue.destination.contents as? MovieDetailsViewController ,
            let indexPath = sender as? IndexPath ,
            let contents = fetchedResultsController?.object(at: indexPath) {
            movieViewController.movie = WMovie(credit: contents)
            
            var persistence = NeedPersistence(isNeeded: true, maxStepCount : 1)
            persistence.incrStepCount()
            
            movieViewController.needsPersistence = persistence
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
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            _items = 2
        } else {
            _items = 3
        }
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
}

fileprivate var _items : CGFloat = 2
fileprivate var _sectionInsets = UIEdgeInsets(top: 10.0 , left: 10.0 , bottom: 10.0 , right: 10.0 )

extension WatchlistViewController : UICollectionViewDelegateFlowLayout {
    
    
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

