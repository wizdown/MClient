//
//  MovieDetailsViewController.swift
//  MClient
//
//  Created by gupta.a on 06/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

fileprivate var itemsPerColumn : CGFloat = 1
fileprivate let sectionInsets = UIEdgeInsets(top: 5.0 , left: 5.0 , bottom: 5.0 , right: 5.0 )

class MovieDetailsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    
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
        getData()
    }

    private func getData() {
        if let contents = movie {
            movieView.movie = contents
            container?.performBackgroundTask{ context in
                let db_movie = try? Movie.findOrCreateMovie(matching: contents, in: context)
                try? context.save()
//                if let db_movie_cast = db_movie?.cast , db_movie_cast.count == 0 {
                if db_movie?.cast?.count == 0 {
                    self.getResults()
                } else {
                    
                    if let db_cast = db_movie?.cast?.sortedArray(using: [NSSortDescriptor(key: "id", ascending: true)]) as? [Person] {
                        var temp_cast = [WCastPeople]()
                        for current_person in db_cast {
                            temp_cast.append(WCastPeople(person: current_person))
                        }
                        DispatchQueue.main.async { [ weak self ] in
                            self?.insertCast(temp_cast)
                        }
                    } else {
                        self.getResults()
                    }
                }
            }
        
        }
    }
    
    private func updateCastInDB(_ cast : [WCastPeople]) {
        container?.performBackgroundTask { context in
            _ = try? Movie.findOrCreateCast(matching: self.movie!, cast: cast, in: context)
            try? context.save()
            print("Cast and Movie Saved")
        }
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
        movieView.castCollectionView.reloadData()
//        movieView.castCollectionView.insertSections([0])
        print("Load ==> Cast Count Found : \(cast.count)")
        
    }
    
    private func getResults(){
        print("Getting Cast results from network")
        if let id = movie?.id {
            let request = WMRequest.castForMovieRequest(movieId: id)
            if request != nil {
                WMovie.performGetCastForAMovieRequest(request: request!) { [weak self] cast in
                    DispatchQueue.main.async { [weak self] in
                        self?.insertCast(cast)
                        self?.updateCastInDB(cast)
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
