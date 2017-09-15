//
//  CastDetailViewController.swift
//  MClient
//
//  Created by gupta.a on 10/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

fileprivate var itemsPerColumn : CGFloat = 1
fileprivate let sectionInsets = UIEdgeInsets(top: 5.0 , left: 5.0 , bottom: 5.0 , right: 5.0 )

class CastDetailViewController: UIViewController , UICollectionViewDataSource , UICollectionViewDelegate {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var needsPersistence : Bool = false
    
    @IBOutlet var castView: CastView!
    
    var _cast: WCastPeople?
    
    private var _movies = [[WMovie]]()
 
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        castView.collectionView.register(UINib(nibName: "newMovieCell", bundle: nil) , forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
        castView.collectionView.delegate = self
        castView.collectionView.dataSource = self
        castView.clearDefaults()
        
        if let contents = _cast {
            spinner?.startAnimating()
            container?.performBackgroundTask{ context in
                let db_person = try? Person.findOrCreatePerson(matching: contents, in: context)
                try? context.save()

                if db_person != nil , db_person!.hasCompleteInfo {
                
//                    // Check for movieCredits only
                    let fetched_person = WCastPeople(person: db_person!)
                    DispatchQueue.main.async {
                        self.updateCast(cast: fetched_person)
                    }
                    

                    if db_person?.movieCredits?.count == 0 {
                        self.getMovieCredits()
                    } else {
                        if let db_movie_credits = db_person?.movieCredits?.sortedArray(using: [NSSortDescriptor(key: "id", ascending: true)]) as? [Movie] {
                            var temp_movieCredits = [WMovie]()
                            for current_credit in db_movie_credits {
                                temp_movieCredits.append(WMovie(credit: current_credit))
                            }
                            DispatchQueue.main.async { [weak self] in
                                self?.insertMovieCredits(movies: temp_movieCredits)
                            }
                        }
                    }
                }
                else {
//                     get Both Info
                    self.getCastDetails()
                    self.getMovieCredits()
                }
            }
        }
        
    }
    
    private func updateMovieCreditsInDB(_ movieCredits : [WMovie]) {
        container?.performBackgroundTask { context in
            _ = try? Person.findOrCreateMovieCredits(matching: self._cast!, movies: movieCredits, in: context)
            try? context.save()
            print("Cast and MovieCredits Saved")
        }
    }
    
    private func updateCompleteCastInDb(_ cast : WCastPeople){
        container?.performBackgroundTask{ context  in
            _ = try? Person.addAditionalPersonDetails(matching: cast, in: context)
            try? context.save()
            print("Cast saved")
        }
    }
    
    private func updateCast(cast: WCastPeople?) {
        if let updatedCast = cast {
                _cast = updatedCast
                print("Load ==> Cast Details Updated")
                castView.cast = _cast
                spinner?.stopAnimating()
                spinner?.removeFromSuperview()
            
        }
        else {
            print("Unable to fetch Cast Details")
        }
        
    }
    
    private func insertMovieCredits(movies: [WMovie]){
        self._movies.removeAll()
        self._movies.insert(movies,at : 0) //2
        //        self.reloadData()
//        castView.collectionView.insertSections([0])
        castView.collectionView.reloadData()
        print("Load ==> Movie Credits Found : \(movies.count)")
    }
    
    private func getMovieCredits(){
        print("Getting movie credits")
        if let id = _cast?.id {
            let request = WCRequest.movieCreditsRequest(castId: id)
            if request != nil {
                WCastPeople.performMovieCreditsRequest(request: request!) { [weak self] movies in
                    DispatchQueue.main.async {
                        self?.insertMovieCredits(movies: movies)
                        self?.updateMovieCreditsInDB(movies)
                    }
                }
            }
        } else {
            print("MoviesCollectionView: Unable to fetch data")
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
                        self?.updateCompleteCastInDb(cast!)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CastToMovie", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let moviesViewController = segue.destination.contents as? MovieDetailsViewController,
                let indexPath = sender as? IndexPath {
                moviesViewController.movie = _movies[indexPath.section][indexPath.row]
                moviesViewController.needsPersistence = self.needsPersistence
//                print("Setting movie for MovieDetailsViewController")
        }
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
//
