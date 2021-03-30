//
//  ReachabilityManager.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/28/21.
//

import Foundation
import Reachability
import TTGSnackbar
import RxSwift

class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()
    
    private var isConnectedSubject = PublishSubject<Bool>()
    var isConnectedObservable: Observable<Bool> {
        return isConnectedSubject.asObservable()
    }
    
    var reachability: Reachability!

    
    override init() {
        super.init()
        
        self.reachability = try! Reachability()
        
        do {
            try reachability.startNotifier()
        } catch let err {
            print(err)
        }

        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)
        
        
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .cellular, .wifi:
            isConnectedSubject.onNext(true)
        case .unavailable:
            isConnectedSubject.onNext(false)
        default:
            break
        }
    }
    
    
    
    
    
    
    
    
}
