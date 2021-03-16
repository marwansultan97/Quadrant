//
//  FavoritePlacesTableViewCell.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/15/21.
//

import UIKit
import MapKit

enum FavoritePlaceType {
    case home
    case work
}

class FavoritePlacesTableViewCell: UITableViewCell {

    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    
    var placeType: FavoritePlaceType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(place: MKPlacemark?) {
        switch self.placeType {
        case .home:
            placeImage.image = UIImage(systemName: "house.fill")
            placeTypeLabel.text = "Home"
            placeAddressLabel.text = "You can add Home Place in the Settings"
            placeAddressLabel.adjustsFontSizeToFitWidth = true
            guard place != nil else {return}
            placeAddressLabel.text = "\(place!.name ?? "") \(place!.thoroughfare ?? "") \(place!.locality ?? "") \(place!.administrativeArea ?? "")"
        case .work:
            placeImage.image = UIImage(systemName: "case.fill")
            placeTypeLabel.text = "Work"
            placeAddressLabel.text = ""
            placeAddressLabel.adjustsFontSizeToFitWidth = true
            guard place != nil else {return}
            placeAddressLabel.text = "\(place!.name ?? "") \(place!.thoroughfare ?? "") \(place!.locality ?? "") \(place!.administrativeArea ?? "")"
        case .none:
            break
        }
        
        
        
    }
    
}
