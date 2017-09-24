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
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var needsPersistence: NeedPersistence = NeedPersistence(isNeeded: false)

    @IBOutlet var castView: CastView!
    
    
    var privateContext : NSManagedObjectContext =
        (UIApplication.shared.delegate as! AppDelegate).pContext
    var _cast: WCastPeople?
    
    private var _movies = [[WMovie]]()
 
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        castView.collectionView.register(UINib(nibName: "newMovieCell", bundle: nil) , forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
        
        castView.collectionView.delegate = self
        castView.collectionView.dataSource = self
        getData()
    }
    
    private func getData(){
        castView.clearDefaults()
        if let _ = _cast {
            spinner.startAnimating()
//            if needsPersistence.required {
//                privateContext.performAndWait {
//                    let _ = Person.create(matching: contents, in: self.privateContext)
//                    try? self.privateContext.save()
//                    print("Attempting to save cast to DB")
//                }
//            }
            getAndDisplayCastAndMovieCredits()
                
            
        }
    }
    
    private func stopAndRemoveSpinner() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        
    }
    
    private func getAndDisplayCastAndMovieCredits(){
        if let contents = _cast {
            if contents.hasCompleteInfo {
                // Found full cast details(yet to check for movie credits) in DB
                print("Full cast details in DB")
                DispatchQueue.main.async { [ weak self ] in
                    self?.stopAndRemoveSpinner()
                    self?.updateCast(cast: contents)
                }
                getAndDisplayMovieCreditsFromNetwork()
            }
            else {
                getAndDisplayCompleteCastFromNetwork()
                // Above method calls getMovieCreditsFromNetwork to synchronously fetch them
            }
        }
    }
    
    private func getAndDisplayCompleteCastFromNetwork() {
        print("Getting Cast Details from network")
        if let contents = _cast {
            let request = WCRequest.castDetailsRequest(castId: contents.id)
            request?.performGetCastDetailsRequest{
                (person: WCastPeople?) in
                if person == nil {
                    print("Unable to fetch cast details from network")
                    // Request For castDetails Failed. Do something here
                    DispatchQueue.main.async{ [weak self ] in
                        self?.stopAndRemoveSpinner()
                        // Add some sort of displayError here
                        self?.updateCast(cast: contents)
                    }
                } else {
                    print("Cast details fetched from network")
                    DispatchQueue.main.async { [weak self ] in
                        self?.stopAndRemoveSpinner()
                        self?.updateCast(cast: person)
                    }
                    self.updateCompleteCastInDb(forPerson: person!)
                    self.getAndDisplayMovieCreditsFromNetwork()
                }
            }
        }
        
    }
    
    
    private func getAndDisplayMovieCreditsFromNetwork() {
        if let contents = _cast {
            print("Fetching Movie Credits from Network")
            let request = WCRequest.movieCreditsRequest(castId: contents.id)
            request?.performMovieCreditsRequest() {
                (movieCredits: [WMovie]) in
                    if movieCredits.count > 0{
                        print("MovieCredits Fetched from Network")
                         DispatchQueue.main.async { [weak self ] in
                            self?.updateMovieCreditsInView(movies: movieCredits)  // done
                        }
                    }else {
                        print("Unable to fetch movie credits from network")
                            // Perform tasks for failure of movie CreditsRequest
                        self.getMovieCreditsFromDb() // make
                }
                
            }
        }
    }

    private func updateCompleteCastInDb(forPerson person: WCastPeople) {
        if needsPersistence.required {
            privateContext.performAndWait {
                print("Updating cast details in DB")
                do {
                    _ = try Person.addAditionalDetails(person, in: self.privateContext)
                    try self.privateContext.save()
                }
                catch{
                    print(error.localizedDescription)
                }
            }
        }
        
    }

    private func updateMovieCreditsInView(movies: [WMovie]){
        self._movies.removeAll()
        self._movies.insert(movies,at : 0)
        castView.collectionView.reloadData()
        print("Load ==> Movie Credits Found : \(movies.count)")
    }

    private func getMovieCreditsFromDb()
    {
        if let contents = _cast ,
            let context = container?.viewContext {
            print("Updating Movie Credits from DB")
            let db_person = Person.find(matching: contents, in: context)
            if let db_movie_credits = db_person?.movieCredits?.sortedArray(using: [NSSortDescriptor(key: "id", ascending: true)]) as? [Movie] {
                var temp_movie_credits = [WMovie]()
                for current_movie_credit in db_movie_credits {
                    temp_movie_credits.append(WMovie(credit: current_movie_credit))
                }
                DispatchQueue.main.async { [weak self] in
                    self?.updateMovieCreditsInView(movies: temp_movie_credits)
                }
            }
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


//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        castView.collectionView.register(UINib(nibName: "newMovieCell", bundle: nil) , forCellWithReuseIdentifier: Constants.movieCellReuseIdentifier)
//        castView.collectionView.delegate = self
//        castView.collectionView.dataSource = self
//        
//        castView.clearDefaults()
//        
//        if let contents = _cast {
//            spinner?.startAnimating()
//            container?.performBackgroundTask{ context in
//                let db_person = try? Person.findOrCreatePerson(matching: contents, in: context)
//                try? context.save()
//
//                if db_person != nil , db_person!.hasCompleteInfo {
//                
////                    // Check for movieCredits only
//                    let fetched_person = WCastPeople(person: db_person!)
//                    DispatchQueue.main.async {
//                        self.updateCast(cast: fetched_person)
//                    }
//                    if db_person?.movieCredits?.count == 0 {
//                        self.getMovieCredits()
//                    } else {
//                        if let db_movie_credits = db_person?.movieCredits?.sortedArray(using: [NSSortDescriptor(key: "id", ascending: true)]) as? [Movie] {
//                            var temp_movieCredits = [WMovie]()
//                            for current_credit in db_movie_credits {
//                                temp_movieCredits.append(WMovie(credit: current_credit))
//                            }
//                            DispatchQueue.main.async { [weak self] in
//                                self?.insertMovieCredits(movies: temp_movieCredits)
//                            }
//                        }
//                    }
//                }
//                else {
////                     get Both Info
//                    self.getCastDetails()
//                    self.getMovieCredits()
//                }
//            }
//        }
//    }
//    
//    private func updateMovieCreditsInDB(_ movieCredits : [WMovie]) {
//        container?.performBackgroundTask { context in
//            _ = try? Person.findOrCreateMovieCredits(matching: self._cast!, movies: movieCredits, in: context)
//            try? context.save()
//            print("Cast and MovieCredits Saved")
//        }
//    }

//    private func updateCompleteCastInDb(_ cast : WCastPeople){
//        container?.performBackgroundTask{ context  in
//            _ = try? Person.addAditionalPersonDetails(matching: cast, in: context)
//            try? context.save()
//            print("Cast saved")
//        }
//    }
//    
//
//   
//    private func getMovieCredits(){
//        print("Getting movie credits")
//        if let id = _cast?.id {
//            let request = WCRequest.movieCreditsRequest(castId: id)
//            if request != nil {
//                request?.performMovieCreditsRequest(request: request!) { [weak self] movies in
//                    DispatchQueue.main.async {
//                        self?.insertMovieCredits(movies: movies)
//                        self?.updateMovieCreditsInDB(movies)
//                    }
//                }
//            }
//        } else {
//            print("MoviesCollectionView: Unable to fetch data")
//        }
//    }

//    private func getCastDetails(){
//        print("Getting Cast Details")
//        if let id = _cast?.id {
//            let request = WCRequest.castDetailsRequest(castId: id)
//            if request != nil {
//                request?.performGetCastDetailsRequest(request: request!) { [weak self] cast in
//                    DispatchQueue.main.async {
//                        self?.updateCast(cast: cast)
//                        self?.updateCompleteCastInDb(cast!)
//                    }
//                }
//            }
//        } else {
//            print("CastDetailsViewController: Unable to fetch data")
//        }
//    }

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


