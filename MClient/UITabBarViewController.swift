//
//  UITabBarViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

class UITabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
////        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: DbManager.writeContext, queue: nil, using: {
////            notification in
////            do {
//////                var count = 1
//////                if let userInfo = notification.userInfo{
//////                    if let inserts = userInfo["inserted"] as? Set<Movie> , inserts.count > 0 {
//////                        print("Inserts!")
//////                        for current_movie in inserts {
//////                            print("\(count) : ")
//////                            print(current_movie.title)
//////                            count = count + 1
//////                        }
////////                        print(inserts)
//////                    }
////////                    print("Newly Inserted")
////////                    print(userInfo["inserted"])
////////                    print("Newly Updated")
////////                    print(userInfo["updated"])
////////                    print("Newly Deleted")
////////                    print(userInfo["deleted"])
//////                }
////                try DbManager.readContext.save()
////                try DbManager.saveContext.save()
////            } catch {
////                print(error.localizedDescription)
////            }
////            //            DbManager.mainContext.mergeChanges(fromContextDidSave: notification)
////        })
//        
//        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: DbManager.writeContext, queue: nil, using: {
//            notification in
////            do {
////                try DbManager.readContext.save()
////                try DbManager.saveContext.save()
////            } catch {
////                print(error.localizedDescription)
////            }
//          
//            DbManager.readContext.mergeChanges(fromContextDidSave: notification)
//        })
//        
//        DbManager.readContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//
//        DbManager.readContext.automaticallyMergesChangesFromParent = true
        
    }
}
