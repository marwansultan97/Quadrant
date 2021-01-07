//
//  PickupController.swift
//  Uber
//
//  Created by Marwan Osama on 12/10/20.
//

import UIKit
import MapKit
import Firebase

protocol PickupControllerDelegate: class {
    func showRoute(trip: Trip)
    func dismiss()
    func searchForAnotherTrip()
}

class PickupController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var acceptTripButton: UIButton!
    @IBOutlet weak var pulsatingView: UIView!
    
    var driverPhoneNumber: String?
    var pulsatingLayer = CAShapeLayer()
    var progressLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()
    var counter = 30
    var timer : Timer?
    
    var trip: Trip? {
        didSet {
            observeCanceledTrip()
        }
    }
    
    var delegate: PickupControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setWaitingValueToTrip()
        configureLayerAnimations()
        setTimer()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureMapView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer?.invalidate()
    }
    
    //MARK: - Timer and Countdown Methods
    
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    @objc func updateCounter() {
        if counter > 0 {
            print(counter)
            self.counter -= 1
        } else {
            print("Move on")
            timer!.invalidate()
            if self.trip?.tripState == .waitingToAccept {
                self.rejectTrip()
            }
        }
    }
    
    //MARK: - Configure UI and Animations

    func configureLayerAnimations() {
        self.progressLayer = setCircleLayers(strokeColor: .systemPink, fillColor: .clear)
        self.pulsatingLayer = setCircleLayers(strokeColor: .clear, fillColor: .white)
        self.trackLayer = setCircleLayers(strokeColor: UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.3), fillColor: .clear)
        pulsatingView.layer.addSublayer(pulsatingLayer)
        pulsatingView.layer.addSublayer(progressLayer)
        pulsatingView.layer.addSublayer(trackLayer)
        pulsatingView.addSubview(mapView)
        setPulsatingAnimation()
        setProgressAnimation(duration: 30) {
        }
    }
    
    func setCircleLayers(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let center = CGPoint(x: 0, y: 0)
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: pulsatingView.frame.width / 2,
                                        startAngle: -(.pi/2), endAngle: (.pi*1.5),
                                        clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.lineWidth = 20
        layer.position = CGPoint(x: pulsatingView.frame.size.width / 2, y: pulsatingView.frame.size.height / 2)
        return layer
    }
    
    
    func setPulsatingAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        self.pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    func setProgressAnimation(duration: TimeInterval, completion: @escaping()-> Void) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
        animation.duration = duration
        animation.toValue = 0
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = 0
        progressLayer.add(animation, forKey: "animateProgress")
    }
    
    func configureUI() {
        acceptTripButton.layer.cornerRadius = acceptTripButton.frame.height/2
    }
    
    
    func configureMapView() {
        mapView.delegate = self
        mapView.layer.cornerRadius = mapView.frame.height/2
        self.mapView.addAnnotation(coordinate: self.trip!.pickupCoordinates)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: self.trip!.pickupCoordinates, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - Configure API methods
    
    func observeCanceledTrip() {
        guard let uid = trip?.passengerUID else {return}
        Service.shared.isTheTripCancled(uid: uid) { (snapshot) in
            self.navigationController?.popViewController(animated: true)
            self.delegate?.dismiss()
        }
    }
    
    func setWaitingValueToTrip() {
        self.trip?.tripState = .waitingToAccept
        guard let uid = trip?.passengerUID else {return}
        REF_TRIPS.child(uid).updateChildValues(["state": TripState.waitingToAccept.rawValue])
    }
    
    func rejectTrip() {
        guard let uid = self.trip?.passengerUID else {return}
        Service.shared.updateTripState(uid: uid, state: .rejected)
        self.navigationController?.popViewController(animated: true)
        self.delegate?.searchForAnotherTrip()
    }
    
    func acceptTrip() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let driverPhoneNumber = self.driverPhoneNumber else {return}
        Service.shared.acceptTheTrip(driverPhoneNumber: driverPhoneNumber, trip: self.trip!) { (err, ref) in
            self.trip?.driverUID = uid
            self.trip?.tripState = .accepted
            self.trip?.driverPhoneNumber = driverPhoneNumber
            self.delegate?.showRoute(trip: self.trip!)
        }
        self.navigationController?.popViewController(animated: true)

    }
    
    
    func showWarningAlert() {
        let alert = UIAlertController(title: "Warning", message: "Do you really want to cancle the trip?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { _ in
            self.rejectTrip()
        }
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    func showConfirmationAlert() {
        let alert = UIAlertController(title: "Confirmation", message: "Do you want to Accept the trip?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { _ in
            self.acceptTrip()
        }
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    

    //MARK: - Button Actions

    @IBAction func cancleButtonTapped(_ sender: UIButton) {
        showWarningAlert()
    }
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        showConfirmationAlert()
    }
}

// MARK: - MapViewDelegate
extension PickupController: MKMapViewDelegate {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        let annotations = mapView.annotations.filter({ $0.isKind(of: MKPointAnnotation.self) })
        mapView.showAnnotations(annotations, animated: true)
    }
    
}
