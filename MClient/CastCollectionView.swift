//
//  CastCollectionView.swift
//  MClient
//
//  Created by gupta.a on 07/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

fileprivate var itemsPerColumn : CGFloat = 1
fileprivate let sectionInsets = UIEdgeInsets(top: 5.0 , left: 5.0 , bottom: 5.0 , right: 5.0 )

class CastCollectionView: UICollectionView , UICollectionViewDelegate, UICollectionViewDataSource {

    private var initialized: Bool = false
    
    private var castForMovieRequest: WCRequest?
    
    var movieId: Int? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    private var _cast = [[WCastPeople]]()
    
    
    // Only override draw() if you perform custom drawing.
//     An empty implementation adversely affects performance during animation.
    
    private func insertCast(_ cast: [WCastPeople]) {
        self._cast.removeAll()
        self._cast.insert(cast,at : 0) //2
        self.reloadData()
        print("Load ==> Cast Count Found : \(cast.count)")

    }
    
    private func initialize(){
        if initialized == false {
            initialized = true
            delegate = self
            dataSource = self
            // Register Cell here
            self.register(UINib(nibName: "NewCastCell", bundle: nil), forCellWithReuseIdentifier: Constants.castCellReuseIdentifier)
        }
    }
    
    private func getResults(){
        if let id = movieId {
            let request = WCRequest.castForMovieRequest(movieId: id)
            if request != nil {
                WCastPeople.performGetCastForAMovieRequest(request: request!) { [weak self] cast in
                    DispatchQueue.main.async {
                        self?.insertCast(cast)
                    }
                }
            }
        } else {
            print("CastCollectionView: MovieId Not Set")
        }
    }
    
    override func draw(_ rect: CGRect) {
        initialize()
        getResults()
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return _cast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return _cast[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.castCellReuseIdentifier, for: indexPath)
        let cast: WCastPeople = _cast[indexPath.section][indexPath.row]
        // Configure the cell
        if let cell = cell as? NewCastCell {
            cell.cast = cast
        }
        return cell
    }
}

extension CastCollectionView : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //2
        let paddingSpace = sectionInsets.left * (itemsPerColumn + 1)
        let availableHeight = frame.height - paddingSpace
        let HeightPerItem = availableHeight / itemsPerColumn
        
        return CGSize(width: HeightPerItem, height: HeightPerItem )
    }
    
//    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
//
//    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }
}
