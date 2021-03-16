//
//  Enumerations.swift
//  Uber
//
//  Created by Marwan Osama on 12/12/20.
//

import Foundation

enum RideActionViewConfiguration {
    case requested
    case accepted
    case driverArrived
    case inProgress
    case arrivedAtDestination
    case completed
}


enum CornerButtonConfiguration {
    case showSideMenu
    case dismissSideMenu
    
    init() {
        self = .showSideMenu
    }
}

enum CircularRegionType: String {
    case pickup
    case destination
}
