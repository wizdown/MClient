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
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: DbManager.privateContext, queue: nil, using: {
            notification in
            try? DbManager.mainContext.save()
            //            DbManager.mainContext.mergeChanges(fromContextDidSave: notification)
        })

        // Do any additional setup after loading the view.
    }

}
