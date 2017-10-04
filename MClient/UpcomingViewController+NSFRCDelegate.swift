//
//  FetchedResultsCollectionViewController.swift
//  MClient
//
//  Created by gupta.a on 14/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

//class FetchedResultsCollectionViewController: MoviesCollectionViewController , NSFetchedResultsControllerDelegate{
extension UpcomingViewController: NSFetchedResultsControllerDelegate {
    
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
//            collectionView.deleteItems(at: [indexPath!])
//            collectionView.insertItems(at: [newIndexPath!])
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

//        }
    }
    
    
}
