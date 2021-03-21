//
//  Extenstions.swift
//  Uber
//
//  Created by Marwan Osama on 12/5/20.
//

import Foundation
import Firebase
import MapKit
import CoreLocation

@available(iOS 13.0, *)
//MARK: - Location Manager Delegate Methods
extension HomeController : CLLocationManagerDelegate {
    
    func authorizationStatus() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch locationManager.accuracyAuthorization {
        case .reducedAccuracy:
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once")
        case .fullAccuracy:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
        
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            break
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus == .authorizedWhenInUse && locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once".localize) { _ in
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
            }
        } else if locationManager.authorizationStatus == .authorizedAlways && locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once".localize) { _ in
                self.locationManager.startUpdatingLocation()
            }
        } else if locationManager.accuracyAuthorization == .fullAccuracy {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        configureMapView(location: userLocation)
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: didFailWithError \(error)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == CircularRegionType.pickup.rawValue {
            print("DEBUG: region is pickup")
        } else {
            print("DEBUG: region is destination")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == CircularRegionType.pickup.rawValue {
            print("DEBUG: did enter pickup region")
            guard let tripUID = self.acceptedTrip?.passengerUID else {return}
            rideActionViewState = .driverArrived
            configRideActionView(place: nil, trip: nil, config: rideActionViewState)
            viewModel.updateTripState(uid: tripUID, state: .driverArrived)
        } else {
            print("DEBUG: did enter destination region")
            guard let tripUID = self.acceptedTrip?.passengerUID else {return}
            rideActionViewState = .arrivedAtDestination
            configRideActionView(place: nil, trip: nil, config: rideActionViewState)
            viewModel.updateTripState(uid: tripUID, state: .arriverAtDestination)
        }
    }
    
    
    func setCircleRegion(identifier: String, coordinate: CLLocationCoordinate2D) {
        let circleRegion = CLCircularRegion(center: coordinate, radius: 20, identifier: identifier)
        locationManager.startMonitoring(for: circleRegion)
    }
}

//MARK: - MapView Delegate Methods
@available(iOS 13.0, *)
extension HomeController: MKMapViewDelegate {

    // to make a custom driver annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let annotationTitle = UILabel(frame: CGRect(x: 2, y: -15, width: 50, height: 30))
            annotationTitle.font = UIFont.systemFont(ofSize: 7)
            annotationTitle.text = annotation.fullname
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "DriverAnnotation")
            annotationView.image = #imageLiteral(resourceName: "icons8-car_top_view")
            annotationView.addSubview(annotationTitle)
            return annotationView
        }
        return nil
    }
    
    // to draw the route between current location and searched place
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        viewModel.uploadDriverLocation()
    }
    
    // to zoom in and out in map
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if !zoomInUser {
            zoomInUser = true
            let annotation = mapView.annotations.filter({ $0.isKind(of: MKUserLocation.self) })
            mapView.showAnnotations(annotation, animated: true)
        } else if zoomInUserAndPoint {
            zoomInUserAndPoint = false
            let zoomInAnnotations = mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            mapView.fitAll(in: zoomInAnnotations, andShow: true)
            animateRideActionViewPassenger(const: 250, alpha: 0)
        
        } else if zoomInUserAndDriver {
            zoomInUserAndDriver = false
            let zoomInAnnotations = mapView.annotations.filter({ !$0.isKind(of: MKPointAnnotation.self) })
            mapView.fitAll(in: zoomInAnnotations, andShow: true)
        }
    }
    
}

//MARK: - Passenger Side Methods
@available(iOS 13.0, *)
extension HomeController: LocationInputControllerDelegate {
    
    
    func deliverPlaceDetails(place: MKPlacemark) {
        self.confirmRideButton.setTitle("CONFIRM REQUEST".localize, for: .normal)
        self.rideActionViewState = .requested
        selectedPlace = place
        cornerButtonState = .dismissSideMenu
        zoomInUserAndPoint = true
        cornerButton.setImage(#imageLiteral(resourceName: "icons8-back"), for: .normal)
        whereToView.alpha = 0
        self.mapView.addAndSelectAnnotation(coordinate: place.coordinate)
        showPlaceRoute(destination: place)
        configRideActionView(place: place, trip: nil, config: self.rideActionViewState)
    }
    
    
    
    func showPlaceRoute(destination: MKPlacemark) {
        
        MapLocationServices.shared.showRoute(destination: destination) { (response, err) in
            guard let polyline = response?.routes.first?.polyline else {return}
            self.mapView.addOverlay(polyline, level: MKOverlayLevel.aboveRoads)
        }
    }
    
}


//MARK: - Driver Side Methods
@available(iOS 13.0, *)
extension HomeController: PickupControllerDelegate {
    
    func searchForAnotherTrip() {
        viewModel.removeObservers(ref: REF_TRIPS, child: nil)
        searchTripsButton.tag = 0
        searchTripsButton.hideLoading()
    }
    

    func dismiss() {
        viewModel.removeObservers(ref: REF_TRIPS, child: nil)
        searchTripsButton.tag = 0
        searchTripsButton.hideLoading()
        self.showAlert(title: "Oops!".localize, message: "The passeneger canceled the Trip".localize)

    }
    
    
    func showRoute(trip: Trip) {
        self.acceptedTrip = trip
        rideActionViewState = .accepted
        self.mapView.addAndSelectAnnotation(coordinate: trip.pickupCoordinates)
        zoomInUserAndPoint = true
        self.setCircleRegion(identifier: CircularRegionType.pickup.rawValue, coordinate: trip.pickupCoordinates)
        let destination = MKPlacemark(coordinate: trip.pickupCoordinates)
        
        MapLocationServices.shared.showRoute(destination: destination) { (response, err) in
            guard let polyline = response?.routes.first?.polyline else {return}
            self.mapView.addOverlay(polyline)
        }
        
        configRideActionView(place: nil, trip: trip, config: self.rideActionViewState)
        self.searchTripsButton.alpha = 0
        viewModel.isTripCanceled(uid: trip.passengerUID) { (snapshot) in
            self.viewModel.removeObservers(ref: REF_TRIPS, child: nil)
            self.configureDriverUI()
            self.searchTripsButton.tag = 0
            self.searchTripsButton.hideLoading()
            self.animateRideActionViewDriver(const: 0)
            self.mapView.removeAnnotationAndOverlays()
            self.showAlert(title: "Oops!".localize, message: "The passeneger canceled the Trip".localize)
        }
    }


}

//MARK: - Activity Indicator View

extension HomeController {
    
    @objc func cancleRide() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        REF_TRIPS.child(uid).removeValue()
        self.startActivityIndicator(false, message: nil)
        self.mapView.removeAnnotationAndOverlays()
        self.cornerButtonState = .showSideMenu
        self.cornerButton.setImage(#imageLiteral(resourceName: "icons8-menu"), for: .normal)
        self.animateRideActionViewPassenger(const: 0, alpha: 1)
    }
    
    func startActivityIndicator(_ show: Bool, message: String?) {
        
        if show {
            
            let view = UIView()
            view.frame = self.view.frame
            view.backgroundColor = .systemBackground
            view.alpha = 0
            view.tag = 1
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.style = .large
            activityIndicator.hidesWhenStopped = true
            
            let label = UILabel()
            label.text = message
            label.textColor = .label
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let button = UIButton()
            let attributedTitle = NSAttributedString(string: "Cancle".localize, attributes: [NSAttributedString.Key.foregroundColor : UIColor.systemBackground])
            button.setAttributedTitle(attributedTitle, for: .normal)
            button.backgroundColor = .label
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(cancleRide), for: .touchUpInside)
            
            
            
            view.addSubview(activityIndicator)
            view.addSubview(label)
            view.addSubview(button)
            
            
            activityIndicator.center = view.center
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 30).isActive = true
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
            button.widthAnchor.constraint(equalToConstant: 100).isActive = true
            button.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            self.view.addSubview(view)
            
            activityIndicator.startAnimating()
            UIView.animate(withDuration: 0.5) {
                view.alpha = 0.7
            }
            
        } else {
            self.view.subviews.forEach { (subview) in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.5) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }

                }
            }
        }
    }
    
}

