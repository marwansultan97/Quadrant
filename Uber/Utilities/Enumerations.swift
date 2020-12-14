//
//  Enumerations.swift
//  Uber
//
//  Created by Marwan Osama on 12/12/20.
//

import Foundation

enum RideActionViewConfiguration {
    case requested
    case acceptedDriverSide
    case acceptedPassengerSide
    
    init() {
        self = .requested
    }
}


enum CornerButtonConfiguration {
    case sideMenu
    case back
    
    init() {
        self = .sideMenu
    }
}
