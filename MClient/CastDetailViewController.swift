//
//  CastDetailViewController.swift
//  MClient
//
//  Created by gupta.a on 10/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

fileprivate var itemsPerColumn : CGFloat = 1
fileprivate let sectionInsets = UIEdgeInsets(top: 5.0 , left: 5.0 , bottom: 5.0 , right: 5.0 )

class CastDetailViewController: UIViewController , UICollectionViewDataSource , UICollectionViewDelegate {

    @IBOutlet var castView: CastView!
    var _cast: WCastPeople?
    
    private var _movies = [[WMovie]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        castView.collectionView.register(UINib(nibName: "NewMovieCell", bundle: nil) , forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
        castView.collectionView.delegate = self
        castView.collectionView.dataSource = self
        if _cast != nil {
            getCastDetails()
        }
        
    }
    
    private func updateCast(cast: WCastPeople?) {
        if let updatedCast = cast {
            _cast = updatedCast
            print("Load ==> Cast Details Updated")
            castView.cast = _cast
        }
        else {
            print("Unable to fetch Cast Details")
        }
        
    }
    
    private func getCastDetails(){
        print("Getting Cast Details")
        if let id = _cast?.id {
            let request = WCRequest.castDetailsRequest(castId: id)
            if request != nil {
                WCastPeople.performGetCastDetailsRequest(request: request!) { [weak self] cast in
                    DispatchQueue.main.async {
                        self?.updateCast(cast: cast)
                    }
                }
            }
        } else {
            print("CastDetailsViewController: Unable to fetch data")
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _movies[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.movieCellReuseIdentifier, for: indexPath)
        let movie: WMovie = _movies[indexPath.section][indexPath.row]
        if let cell = cell as? newMovieCell {
            cell.movie = movie
        }
        return cell
    }
    
}

extension CastDetailViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerColumn + 1)
        let availableHeight = castView.collectionView.frame.height - paddingSpace
        let HeightPerItem = availableHeight / itemsPerColumn
        
        return CGSize(width: HeightPerItem, height: HeightPerItem )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
    }
}
