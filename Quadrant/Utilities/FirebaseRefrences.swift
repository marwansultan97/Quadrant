//
//  FirebaseRefrences.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/23/21.
//

import Foundation
import Firebase


let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATION = DB_REF.child("driver-locations")
let REF_USER_LOCATION = DB_REF.child("user-location")
let REF_TRIPS = DB_REF.child("trips")
let REF_FAVORITE_PLACES = DB_REF.child("favorite-places")
let REF_COMPLETED_TRIPS = DB_REF.child("completed_trips")
let REF_TEXT = DB_REF.child("text")
