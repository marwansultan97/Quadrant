//
//  YourTripsTableViewCell.swift
//  Uber
//
//  Created by Marwan Osama on 12/28/20.
//

import UIKit
import CoreLocation

class YourTripsTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var phonenumberLabel: UILabel!
    
    static let identifier = "YourTripsCell"
    
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

    func configureCell(trip: Trip, user: User) {
        reverseGeoCode(trip: trip) { (pickupAddress) in
            self.pickupLabel.text = "From".localize + " " + "\(pickupAddress)"
            self.destinationLabel.text = "To".localize + " " + "\(trip.destinationName ?? "")"
            self.dateLabel.text = trip.date
            self.dateLabel.adjustsFontSizeToFitWidth = true
            if user.accountType == .passenger {
                self.phonenumberLabel.text = "Driver Phone number:".localize + " " + "\(trip.driverPhoneNumber ?? "")"
            } else {
                self.phonenumberLabel.text = "Passenger Phone number:".localize + " " + "\(trip.passengerPhoneNumber ?? "")"
            }
        }


    }

}
