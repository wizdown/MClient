//
//  MovieDetailsViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

fileprivate var itemsPerColumn : CGFloat = 1
fileprivate let sectionInsets = UIEdgeInsets(top: 5.0 , left: 5.0 , bottom: 5.0 , right: 5.0 )

class MovieDetailsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {

    @IBOutlet weak var movieView: MovieView! {
        didSet{
            movieView.castCollectionView.delegate = self
            movieView.castCollectionView.dataSource = self
        }
    }
    
    var movie : WMovie?
    
    private var _cast = [[WCastPeople]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieView.castCollectionView.register(UINib(nibName: "NewCastCell", bundle: nil), forCellWithReuseIdentifier: Constants.castCellReuseIdentifier)
        _cast.removeAll()
        if let contents = movie {
            movieView.movie = contents
            getResults()
        }
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "castDetailSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let castDetailViewController = segue.destination.contents as? CastDetailViewController ,
            let indexPath = sender as? IndexPath {
            castDetailViewController._cast = _cast[indexPath.section][indexPath.row]
            print("Setting Cast for Cast Details")
        }
    }
    
    private func insertCast(_ cast: [WCastPeople]) {
        self._cast.removeAll()
        self._cast.insert(cast,at : 0) //2
        //        self.reloadData()
        movieView.castCollectionView.insertSections([0])
        print("Load ==> Cast Count Found : \(cast.count)")
        
    }
    
    private func getResults(){
        print("Getting Cast results")
        if let id = movie?.id {
            let request = WMRequest.castForMovieRequest(movieId: id)
            if request != nil {
                WMovie.performGetCastForAMovieRequest(request: request!) { [weak self] cast in
                    DispatchQueue.main.async {
                        self?.insertCast(cast)
                    }
                }
            }
        } else {
            print("CastCollectionView: Unable to fetch data")
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _cast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _cast[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.castCellReuseIdentifier, for: indexPath)
        let cast: WCastPeople = _cast[indexPath.section][indexPath.row]
        if let cell = cell as? NewCastCell {
            cell.cast = cast
        }
        return cell
    }

}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

extension MovieDetailsViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerColumn + 1)
        let availableHeight = movieView.castCollectionView.frame.height - paddingSpace
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
