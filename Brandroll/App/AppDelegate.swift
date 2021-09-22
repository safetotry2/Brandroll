//
//  AppDelegate.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/8/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    //var firebaseToekn: String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        FirebaseApp.configure()
        
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = true
        
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().shadowImage = nil
        
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    func attemptToRegisterForNotifications(application: UIApplication) {
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { [weak self] authorized, error in
            if authorized {
                PushHelper.shared.setAllNotificationsToOnOnce()
                PushHelper.shared.setAllowAllNotifications(true)
                self?.setUserFCMToken()
            } else {
                PushHelper.shared.setAllowAllNotifications(false)
            }
        }
        
        application.registerForRemoteNotifications()
        
    }
    
    func setUserFCMToken() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
        
        let values = ["fcmToken": fcmToken]
        
        USER_REF.child(currentUid).updateChildValues(values)
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("DEBUG: Registered for notifications with device token: ", deviceToken)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("DEBUG: Registered with FCM Token: ", fcmToken as Any)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      if UIApplication.shared.applicationState == .active {
        completionHandler(UNNotificationPresentationOptions(rawValue: 0))
      } else {
        completionHandler([.alert, .sound, .badge])
      }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

