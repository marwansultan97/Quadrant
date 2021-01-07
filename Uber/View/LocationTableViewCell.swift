//
//  LocationTableViewCell.swift
//  Uber
//
//  Created by Marwan Osama on 11/29/20.
//

import UIKit
import Hero
import MapKit

class LocationTableViewCell: UITableViewCell {

    static let identifier = "LocationCell"
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
