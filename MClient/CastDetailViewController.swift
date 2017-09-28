//
//  CastDetailViewController.swift
//  MClient
//
//  Created by gupta.a on 10/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit
import CoreData

class CastDetailViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource  {
    
    private let networkManager = NetworkManager()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var needsPersistence: NeedPersistence = NeedPersistence(isNeeded: false)

    @IBOutlet var castView: CastView!
    
    var _cast: WCastPeople?
    
    private var _movies = [[WMovie]]()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        castView.collectionView.register(UINib(nibName: "newMovieCell", bundle: nil) , forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
        
        castView.collectionView.delegate = self
        castView.collectionView.dataSource = self
        getCastAndMovieCredits()
    }
    
    private func getCastAndMovieCredits(){
        castView.clearDefaults()
        if let contents = _cast {
            spinner.startAnimating()
            if let person = DbManager.getPerson(withId: contents.id) ,
                person.hasCompleteInfo {
                    // Found full cast details(yet to check for movie credits) in DB
                    print("Full cast details in DB")
                    DispatchQueue.main.async { [ weak self ] in
                        self?.stopAndRemoveSpinner()
                        self?.updateCast(cast: person)
                    }
                    getAndDisplayMovieCreditsFromNetwork()
                }
            else {
                getAndDisplayCastFromNetwork(forPerson: contents)
                // Above method calls getMovieCreditsFromNetwork to synchronously fetch them
            }
        }
     
    }
    
    private func stopAndRemoveSpinner() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    private func CastCompletionHandler(_ person : WCastPeople? ) {
        if let contents = _cast {
            var new_person: WCastPeople = contents
            
            if person == nil {
                print("Unable to fetch cast details from network")
                
            } else {
                print("Cast details fetched from network")
                new_person = person!
                self.getAndDisplayMovieCreditsFromNetwork()
            }
            DispatchQueue.main.async { [ weak self ] in
                self?.stopAndRemoveSpinner()
                self?.updateCast(cast: new_person)
            }
        }
    }
    
    private func getAndDisplayCastFromNetwork(forPerson person : WCastPeople) {
        networkManager.getPersonDetails(for: person, completion: CastCompletionHandler(_:))
    }
    
    private func MovieCreditsCompletionHandler(_ movieCredits : [WMovie] ) {
        if movieCredits.count > 0 {
            print("MovieCredits Fetched from Network")
            DispatchQueue.main.async { [weak self ] in
                self?.updateMovieCreditsInView(movies: movieCredits)  // done
            }
        }else {
            print("Fetching Movie Credits from Network")
            // Perform tasks for failure of movie CreditsRequest
            if let contents = _cast {
                let temp_movie_credits = DbManager.getMovieCredits(forPersonWithId: contents.id)
                DispatchQueue.main.async { [weak self ] in
                    self?.updateMovieCreditsInView(movies: temp_movie_credits)  // done
                }
            }
            
        }
    }
    
    private func getAndDisplayMovieCreditsFromNetwork() {
        if let id = _cast?.id {
            print("Fetching Movie Credits from Network")
            networkManager.getMovieCredits(forPersonId: id, completion: MovieCreditsCompletionHandler(_:))
        }
    }

    private func updateMovieCreditsInView(movies: [WMovie]){
        self._movies.removeAll()
        self._movies.insert(movies,at : 0)
        castView.collectionView.reloadData()
        print("Load ==> Movie Credits Found : \(movies.count)")
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
                var persistence = self.needsPersistence
                persistence.incrStepCount()
                moviesViewController.needsPersistence = persistence
//                moviesViewController.needsPersistence.incrStepCount()
//                print("Setting movie for MovieDetailsViewController")
        }
    }
}

fileprivate var _items : CGFloat = 1
fileprivate var _sectionInsets = UIEdgeInsets(top: 5.0 , left: 5.0 , bottom: 5.0 , right: 5.0 )

extension CastDetailViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = _sectionInsets.left * ( _items + 1 )
        let availableHeight = collectionView.frame.height - paddingSpace
        let HeightPerItem = availableHeight / _items
        return CGSize(width: HeightPerItem, height: HeightPerItem )
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return _sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return _sectionInsets.left
    }
}


