//
//  NowPlayingExViewController.swift
//  MClient
//
//  Created by gupta.a on 15/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

extension NowPlayingViewController: NSFetchedResultsControllerDelegate {

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //        print("Content about to change")
        //        _collectionView?.reloadData()
    }
    
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: _collectionView?.insertSections([sectionIndex])
        case .delete: _collectionView?.deleteSections([sectionIndex])
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            _collectionView?.insertItems(at: [newIndexPath!])
        case .delete:
            _collectionView?.deleteItems(at: [indexPath!])
        case .update:
            _collectionView?.reloadItems(at: [indexPath!])
        case .move:
            _collectionView?.deleteItems(at: [indexPath!])
            _collectionView?.insertItems(at: [newIndexPath!])
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //        print("Content Updated")
        //        _collectionView?.reloadData()
    }
    

}
