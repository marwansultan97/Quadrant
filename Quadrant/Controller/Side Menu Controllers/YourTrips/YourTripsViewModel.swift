//
//  YourTripsViewModel.swift
//  Uber
//
//  Created by Marwan Osama on 1/9/21.
//

import Foundation
import Combine
import Firebase

class YourTripsViewModel {
    
    let uid = Auth.auth().currentUser?.uid ?? ""
    let services = Service.shared
    @Published var trips = [Trip]()
    
    init() {
        fetchTrips()
    }
    
    func fetchTrips() {
        
        services.fetchCompletedTrips { (trips) in
            self.trips = trips
        }
        
    }
    
    
    
    
    
}
