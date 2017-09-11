//
//  CastView.swift
//  MClient
//
//  Created by gupta.a on 11/09/17.
//  Copyright © 2017 gupta.a. All rights reserved.
//

import UIKit

class CastView: UIView {
    
    @IBOutlet weak var poster: UIImageView!
    
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var date_of_birth: UILabel!
    
    @IBOutlet weak var place_of_birth: UILabel!
    
    @IBOutlet weak var biography: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var cast : WCastPeople? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    private func updateUI() {
        
        let castId = cast?.id
        var imageURL: URL?
        imageURL = cast?.getFullBackdropImageURL()
    
        DispatchQueue.global(qos: .userInteractive ).async { [weak self] in
            if let url = imageURL ,
                let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async { [weak self ] in
                    if castId == self?.cast?.id {
                        self?.poster.image = UIImage(data: imageData)
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self ] in
                    self?.poster.image = UIImage(named: "imageNotFound")
                }
            }
            
        }
        
        if let dob = cast?.date_of_birth?.description.components(separatedBy: " ")[0] {
            date_of_birth.text = dob
        }
        else {
            date_of_birth.text = Constants.notFound
        }
    
        name.text = cast?.name
        
        gender.text = cast?.gender
        
        place_of_birth.text = cast?.place_of_birth
        
        biography.text = cast?.biography
    }
    
    override func draw(_ rect: CGRect) {
        updateUI()
    }

}
