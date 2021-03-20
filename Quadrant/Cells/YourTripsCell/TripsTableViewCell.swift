//
//  TripsTableViewCell.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/19/21.
//

import UIKit
import GeoFire

enum TripsCellType {
    case passenger
    case driver
}

class TripsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var pickupLocationLabel: UILabel!
    @IBOutlet weak var destinationLocationLabel: UILabel!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var cellUseCase: TripsCellType?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reverseGeoCode(trip: Trip, completion: @escaping(String)-> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: trip.pickupCoordinates.latitude, longitude: trip.pickupCoordinates.longitude)
        geocoder.reverseGeocodeLocation(location) { (placeMarks, err) in
            guard err == nil else {
                print("DEBUG: err geocoding \(err!.localizedDescription)")
                return
            }
            guard let pm = placeMarks?.first else {return}
            var addressString: String = ""
            if pm.subLocality != nil {
                addressString = addressString + pm.subLocality! + ", "
            }
            if pm.thoroughfare != nil {
                addressString = addressString + pm.thoroughfare! + ", "
            }
            if pm.locality != nil {
                addressString = addressString + pm.locality! + ", "
            }
            if pm.country != nil {
                addressString = addressString + pm.country! + ", "
            }
            if pm.postalCode != nil {
                addressString = addressString + pm.postalCode! + " "
            }
            completion(addressString)
        }
    }

    func configureCell(trip: Trip) {
        reverseGeoCode(trip: trip) { [weak self] (pickupAddress) in
            guard let self = self else { return }
            self.pickupLocationLabel.text = "\(pickupAddress)"
            self.destinationLocationLabel.text = "\(trip.destinationName ?? "")"
            self.dateLabel.text = trip.date
            self.pickupLocationLabel.adjustsFontSizeToFitWidth = true
            self.destinationLocationLabel.adjustsFontSizeToFitWidth = true
            
            switch self.cellUseCase {
            
            case .passenger:
                self.personNameLabel.text = "\(trip.driverName ?? "")"
                self.phoneNumberLabel.text = "\(trip.driverPhoneNumber ?? "")"
                
            case .driver:
                self.personNameLabel.text = "\(trip.passengerName ?? "")"
                self.phoneNumberLabel.text = "\(trip.passengerPhoneNumber ?? "")"
                
            case .none:
                break
            }
        }
        
        
    }
    
    
    
    
    
}
