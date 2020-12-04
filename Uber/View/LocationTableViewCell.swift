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

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(place: MKPlacemark) {
//        self.hero.isEnabled = true
//        self.hero.modifiers = [.translate(x: 50, y: 50, z: 0)]
        guard let thoroughFare = place.thoroughfare else {return}
        guard let subThoroughFare = place.subThoroughfare else {return}
        guard let locality = place.locality else {return}
        guard let adminArea = place.administrativeArea else {return}
        locationLabel.text = place.name
        addressLabel.text = "\(subThoroughFare) \(thoroughFare) \(locality) \(adminArea)"
        addressLabel.alpha = 0.7
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.minimumScaleFactor = 0.2
    }


}
