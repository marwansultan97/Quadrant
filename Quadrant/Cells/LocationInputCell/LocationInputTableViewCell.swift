//
//  LocationInputTableViewCell.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/14/21.
//

import UIKit
import MapKit

class LocationInputTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(place: MKPlacemark) {
        let thoroughFare = place.thoroughfare
        let subThoroughFare = place.subThoroughfare
        let locality = place.locality
        let adminArea = place.administrativeArea
        locationLabel.text = place.name ?? ""
        addressLabel.text = "\(subThoroughFare ?? "") \(thoroughFare ?? "") \(locality ?? "") \(adminArea ?? "")"
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.minimumScaleFactor = 0.2
    }
    
}
