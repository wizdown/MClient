//
//  CastView.swift
//  MClient
//
//  Created by gupta.a on 11/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class CastView: UIView {
    
    @IBOutlet weak var nameHeader: UILabel!
    @IBOutlet weak var genderHeader: UILabel!
    @IBOutlet weak var dobHeader: UILabel!
    @IBOutlet weak var placeOfBirthHeader: UILabel!
    @IBOutlet weak var biographyHeader: UILabel!
    @IBOutlet weak var actedInHeader: UILabel!
    
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var date_of_birth: UILabel!
    @IBOutlet weak var place_of_birth: UILabel!
    @IBOutlet weak var biography: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
     func clearDefaults(){
        nameHeader.text = ""
        genderHeader.text = ""
        dobHeader.text = ""
        placeOfBirthHeader.text = ""
        biographyHeader.text = ""
        actedInHeader.text = ""
        name.text = ""
        gender.text = ""
        date_of_birth.text = ""
        place_of_birth.text = ""
        biography.text = ""
    }
    
    private func setDefaults(){
        nameHeader.text = "Name"
        genderHeader.text = "Gender : "
        dobHeader.text = "Date Of Birth : "
        placeOfBirthHeader.text = "Place Of Birth"
        biographyHeader.text = "Biography"
        actedInHeader.text = "Acted In"
    }
    
    var cast : WCastPeople? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    private func getAndDisplayProfileImageFromCache() {
        if let url = cast?.getFullBackdropImageURL() {
            poster.sd_setImage(with: url, placeholderImage: UIImage(named: "loading"))
        }
    }
    
//    private func getAndDisplayProfileImageFromNetwork() {
//        let castId = cast?.id
//        var imageURL: URL?
//        imageURL = cast?.getFullBackdropImageURL()
//        
//        DispatchQueue.global(qos: .userInteractive ).async { [weak self] in
//            if let url = imageURL ,
//                let imageData = try? Data(contentsOf: url) {
//                DispatchQueue.main.async { [weak self ] in
//                    if castId == self?.cast?.id {
//                        self?.poster.image = UIImage(data: imageData)
//                    }
//                }
//            } else {
//                DispatchQueue.main.async { [weak self ] in
//                    self?.poster.image = UIImage(named: "imageNotFound")
//                }
//            }
//            
//        }
//    }
    
    private func updateUI() {
        
        if let person = cast {
            setDefaults()
            poster.image = UIImage(named: "loading")
            
            getAndDisplayProfileImageFromCache()
            
            if let dob = person.date_of_birth?.description.components(separatedBy: " ")[0] {
                date_of_birth.text = dob
            }
            else {
                date_of_birth.text = Constants.notFound
            }
            
            name.text = person.name
            gender.text = person.gender
            place_of_birth.text = person.place_of_birth
            biography.text = person.biography
        }
    }
    
    override func draw(_ rect: CGRect) {
        updateUI()
    }

}
