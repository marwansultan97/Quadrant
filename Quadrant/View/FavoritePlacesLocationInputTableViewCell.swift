//
//  FavoritePlacesLocationInputTableViewCell.swift
//  Uber
//
//  Created by Marwan Osama on 12/25/20.
//

import UIKit
import MapKit

class FavoritePlacesLocationInputTableViewCell: UITableViewCell {

    static let identifier = "FavoritePlacesCell"
    
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(place: MKPlacemark?, image: UIImage, placeType: String) {
        
        placeImage.image = image
        placeImage.tintColor = .black
        placeTypeLabel.text = placeType.localize
        placeAddressLabel.text = ""
        placeAddressLabel.adjustsFontSizeToFitWidth = true
        guard place != nil else {return}
        placeAddressLabel.text = "\(place!.name ?? "") \(place!.thoroughfare ?? "") \(place!.locality ?? "") \(place!.administrativeArea ?? "")"
        
        
    }

}
