//
//  AppDelegate.swift
//  Uber
//
//  Created by Marwan Osama on 11/19/20.
//

import UIKit
import Firebase
import UserNotifications
import Reachability
import TTGSnackbar

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    let reachability = ReachabilityManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = UIStoryboard(name: "Launch", bundle: nil).instantiateInitialViewController()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert,.sound,.badge)
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, err) in
            if let err = err {
                print("UserNotification Auth \(err)")
            }
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)
//        do{
//            try reachability.startNotifier()
//        }catch{
//            print("could not start reachability notifier")
//        }
        
        
        
        return true
    }
    
//    @objc func reachabilityChanged(notification: Notification) {
//        let reachability = notification.object as! Reachability
//        switch reachability.connection {
//        case .wifi, .cellular:
//            print("Connected")
//        case .unavailable:
//            print("Disconnected")
//        default:
//            break
//        }
//    }
    
    
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("DEBUG: did discard scene sessions")
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
}
