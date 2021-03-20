//
//  PickupViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/16/21.
//

import UIKit
import MapKit
import RxCocoa
import RxSwift

class PickupViewController: UIViewController {
    
    
    @IBOutlet weak var pulsatingView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var trip: Trip?
    var driverUser: User?
    
    private let bag = DisposeBag()
    private var viewModel = PickupDViewModel()
    
    var isRejectedBehavior = BehaviorRelay<Bool>(value: false)
    var isCanceledBehavior = BehaviorRelay<Bool>(value: false)
    var isAcceptedBehavior = BehaviorRelay<Trip?>(value: nil)
    
    var pulsatingLayer = CAShapeLayer()
    var progressLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()
    var counter = 15
    var timer : Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.updateTripState(uid: trip!.passengerUID, state: .waitingToAccept)
        viewModel.isTheTripCancled(uid: trip!.passengerUID)
        configureUI()
        observeIfTheTripCanceled()
        acceptButtonTapped()
        rejectButtonTapped()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureMapView()
        setTimer()
        configureLayerAnimations()
    }
    
    private func observeIfTheTripCanceled() {
        viewModel.isTheTripCanceledBehavior.subscribe(onNext: { [weak self] isTheTripCanceled in
            if isTheTripCanceled {
                self?.isCanceledBehavior.accept(true)
                self?.timer?.invalidate()
                self?.dismiss(animated: true)
            }
        }).disposed(by: bag)
    }
    
    private func configureUI() {
        mapView.layer.cornerRadius = mapView.frame.height / 2
        acceptButton.layer.cornerRadius = 10
        rejectButton.layer.cornerRadius = 10
        
        acceptButton.layer.shadowColor = UIColor.gray.cgColor
        acceptButton.layer.shadowOffset = CGSize.zero
        acceptButton.layer.shadowOpacity = 1
        acceptButton.layer.shadowRadius = 5
        
        rejectButton.layer.shadowColor = UIColor.gray.cgColor
        rejectButton.layer.shadowOffset = CGSize.zero
        rejectButton.layer.shadowOpacity = 1
        rejectButton.layer.shadowRadius = 5
        
    }
    
    private func configureMapView() {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: self.trip!.pickupCoordinates, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAndSelectAnnotation(coordinate: self.trip!.pickupCoordinates)
        let zoomInAnnotations = mapView.annotations.filter({ $0.isKind(of: MKPointAnnotation.self) })
        mapView.showAnnotations(zoomInAnnotations, animated: true)
    }
    

    private func acceptButtonTapped() {
        acceptButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showConfirmationAlert()
            }).disposed(by: bag)
    }
    
    private func rejectButtonTapped() {
        rejectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showWarningAlert()
            }).disposed(by: bag)
    }
    
    private func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    @objc func updateCounter() {
        if counter > 0 {
            print(counter)
            self.counter -= 1
        } else {
            viewModel.updateTripState(uid: trip!.passengerUID, state: .rejected)
            self.isRejectedBehavior.accept(true)
            self.timer?.invalidate()
            self.dismiss(animated: true)
            timer!.invalidate()
        }
    }
    
    func configureLayerAnimations() {
        self.trackLayer = setCircleLayers(strokeColor: .systemGray3, fillColor: .clear)
        self.progressLayer = setCircleLayers(strokeColor: .label, fillColor: .clear)
        self.pulsatingLayer = setCircleLayers(strokeColor: .clear, fillColor: UIColor(hexString: "C90000"))
        
        pulsatingView.layer.addSublayer(pulsatingLayer)
        pulsatingView.layer.addSublayer(trackLayer)
        pulsatingView.layer.addSublayer(progressLayer)
        pulsatingView.addSubview(mapView)
        setPulsatingAnimation()
        setProgressAnimation(duration: 15)
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
    
    func setProgressAnimation(duration: TimeInterval) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
        animation.duration = duration
        animation.toValue = 0
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = 0
        progressLayer.add(animation, forKey: "animateProgress")
    }
    
    private func showWarningAlert() {
        let alert = UIAlertController(title: "Warning", message: "Do you really want to reject the trip?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.viewModel.updateTripState(uid: self.trip!.passengerUID, state: .rejected)
            self.isRejectedBehavior.accept(true)
            self.timer?.invalidate()
            self.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    private func showConfirmationAlert() {
        let alert = UIAlertController(title: "Confirmation", message: "Do you want to Accept the trip?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { _ in
            self.timer?.invalidate()
            self.viewModel.acceptTheTrip(driverUser: self.driverUser!, trip: self.trip!)
            self.trip?.tripState = .accepted
            self.trip?.driverName = self.driverUser!.firstname + " " + self.driverUser!.surname
            self.trip?.driverPhoneNumber = self.driverUser?.phonenumber
            
            self.isAcceptedBehavior.accept(self.trip)
            self.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    

}
