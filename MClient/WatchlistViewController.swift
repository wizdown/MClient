//
//  WatchlistViewController.swift
//  MClient
//
//  Created by gupta.a on 20/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

fileprivate var itemsPerRow : CGFloat = 2
fileprivate let sectionInsets = UIEdgeInsets(top: 10.0 , left: 10.0 , bottom: 10.0 , right: 10.0 )


class WatchlistViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , NSFetchedResultsControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    private var isWatchListEnabled : Bool = false
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<Movie>?
    
    private func updateUserDataInUI() {
//        userImage.layer.borderWidth = 1
//        userImage.layer.masksToBounds = false
//        userImage.layer.borderColor = UIColor.white.cgColor
//        userImage.layer.cornerRadius = userImage.frame.height/2
//        userImage.clipsToBounds = true
        
        var welcomeMessage = ""
        if isWatchListEnabled {
            let username = UserDefaults.standard.string(forKey: Constants.key_username)
            if username != nil {
                welcomeMessage.append("\(username!)'s ")
            }
            welcomeMessage.append("watchlist")
        }
        else {
            welcomeMessage.append("Please login to use this feature")
        }
        welcomeLabel.text = welcomeMessage
    }
    
    private func verifyLogin() {
        let account_id = UserDefaults.standard.string(forKey: Constants.key_account_id)
        let session_id = UserDefaults.standard.string(forKey: Constants.key_session_id)
        if account_id != nil && session_id != nil {
            isWatchListEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyLogin()
        
        updateUserDataInUI()
        
        if isWatchListEnabled {
            
            collectionView.register(UINib(nibName: "newMovieCell", bundle: nil), forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
            collectionView.delegate = self
            collectionView.dataSource = self
            
            if let context = container?.viewContext {
                
                let request: NSFetchRequest<Movie> = Movie.fetchRequest()
                request.predicate = NSPredicate(format: "isInWatchlist = %@", true as CVarArg)
                request.sortDescriptors = [NSSortDescriptor(key : "timestamp" , ascending: true )]
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
                collectionView.reloadData()
            }
            
            NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil, using: {
                [weak self]
                notification in
                //            print(notification.userInfo ?? "")
                self?.container?.viewContext.mergeChanges(fromContextDidSave: notification)
            })
        }
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
            
//            var persistence = NeedPersistence(isNeeded: true)
//            persistence.incrStepCount()
//            
//            movieViewController.needsPersistence = persistence
        }
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //        print("Content about to change")
        //        _collectionView?.reloadData()
    }
    
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: collectionView.insertSections([sectionIndex])
        case .delete: collectionView.deleteSections([sectionIndex])
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.deleteItems(at: [indexPath!])
            collectionView?.insertItems(at: [newIndexPath!])
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //        print("Content Updated")
        //        _collectionView?.reloadData()
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

extension WatchlistViewController : UICollectionViewDelegateFlowLayout {
    
    
    //    1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem )
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
