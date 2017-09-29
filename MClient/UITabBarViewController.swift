//
//  UITabBarViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class UITabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: DbManager.writeContext, queue: nil, using: {
            notification in
            do {
                try DbManager.readContext.save()
                try DbManager.saveContext.save()
            } catch {
                print(error.localizedDescription)
            }
            //            DbManager.mainContext.mergeChanges(fromContextDidSave: notification)
        })
    }

}
