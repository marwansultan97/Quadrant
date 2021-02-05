//
//  FavoritePlacesTableViewCell.swift
//  Uber
//
//  Created by Marwan Osama on 12/25/20.
//

import UIKit
import MapKit

class FavoritePlacesSettingsTableViewCell: UITableViewCell {

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
        placeImage.tintColor = .label
        placeTypeLabel.text = placeType.localize
        placeAddressLabel.text = "Add \(placeType)".localize
        placeAddressLabel.alpha = 0.7
        placeAddressLabel.adjustsFontSizeToFitWidth = true
        guard place != nil else {return}
        placeAddressLabel.alpha = 1
        placeAddressLabel.text = "\(place!.name ?? "") \(place!.thoroughfare ?? "") \(place!.locality ?? "") \(place!.administrativeArea ?? "")"
        
        
    }

}
