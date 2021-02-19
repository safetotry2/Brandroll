//
//  MainTabVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/13/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Properties
    
    let dot = UIView()
    var notificationIDs = [String]()
    private var notifRefHandle: DatabaseHandle?
    private var notifRefHandleChildAdded: DatabaseHandle?
    
    private (set)var feedVC: FeedVC!
    private (set)var searchVC: SearchVC!
    private (set)var notificationsVC: NotificationsVC!
    private (set)var userProfileVC: UserProfileVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate
        self.delegate = self
        
        // configure view controllers
        configureViewControllers()
        
        // configure notification dot
        configureNotificationDot()
        
        // observe notifications
        observeNotifications()
        
        // user validation
        checkIfUserIsLoggedIn()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: tabBarNotificationKey, object: nil)
        
    }
    
    // MARK: - Handlers
    
    @objc func notificationReceived(_ notification: Foundation.Notification) {
        guard let isHidden = notification.userInfo?["isHidden"] as? Bool else { return }
        self.setTabBar(hidden: isHidden)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // function to create view controllers that exist within the tab bar
    func configureViewControllers() {
        
        // home feed controller
        feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        let feedNavCon = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: feedVC)
        
        // search feed controller
        searchVC = SearchVC()
        let searchNavCon = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: searchVC)
        
        // select image controller
        let selectImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        // notification controller
        notificationsVC = NotificationsVC()
        let notificationsNavCon = constructNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: notificationsVC)
        
        // profile controller
        userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        let userProfileNavCon = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: userProfileVC)
        
        // view controller to be added to tab controller
        viewControllers = [
            feedNavCon,
            searchNavCon,
            selectImageVC,
            notificationsNavCon,
            userProfileNavCon
        ]
        
        //tab bar tint color
        tabBar.tintColor = .black
    }
    
    // construct navigation controller
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        // construct nav controller
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        // return nav controller
        return navController
    }
    
    func configureNotificationDot() {
        
        if UIDevice().userInterfaceIdiom == .phone {
            
            let tabBarHeight = tabBar.frame.height
            
            // This is the actual height of the iPhone 10 screen
            if UIScreen.main.nativeBounds.height == 2436 {
                // configure dot for iPhone X, iPhone XS, iPhone 11 Pro
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            } else if UIScreen.main.nativeBounds.height == 1792 {
               // configure dot for iPhone XR and iPhone 11
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            } else {
                // configure dot for other phone models
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)
            }
            
            // create dot
            let frame1 = (view.frame.width / 5) * 3
            let frame2 = (view.frame.width / 5) / 2
            let frame1And2 = frame1 + frame2
            dot.center.x = frame1And2
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
            dot.layer.cornerRadius = dot.frame.width / 2
            view.addSubview(dot)
            dot.isHidden = true
        }
    }
    
    
    // MARK: - UITabBar
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
            
            return false
        } else if index == 3 {
            dot.isHidden = true
            return true
        }
        return true
    }
    
    // MARK: - Public
    
    func didLogIn() {
        observeNotifications()
    }
    
    func didLogout() {
        if let currentUid = Auth.auth().currentUser?.uid {
            if let notifRefHandle = self.notifRefHandle {
                NOTIFICATIONS_REF.child(currentUid)
                    .removeObserver(withHandle: notifRefHandle)
            }
            if let notifRefHandleChildAdded = self.notifRefHandleChildAdded {
                NOTIFICATIONS_REF.child(currentUid)
                    .removeObserver(withHandle: notifRefHandleChildAdded)
            }
        }
    }
    
    // MARK: - API
    
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                // present login controller
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
    }
    
    private func observeNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.notificationIDs.removeAll()
        
        self.dot.isHidden = true
        
        notifRefHandle = NOTIFICATIONS_REF
            .child(currentUid)
            .observe(.value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let notificationId = snapshot.key
                                        
                    guard let dic = snapshot.value as? [String : AnyObject],
                          let userIdFromNotification = dic["uid"] as? String else { return }
                    
                    let appNotif = AppNotif(key: notificationId, user: nil, dictionary: dic)
                    self.setDotNotifToHiddenIfPossibleForChatController(userIdFromNotification: userIdFromNotification, appNotif: appNotif)
                }
                
                self.notificationsVC.newObservedNotification(allObjects)
            }
        
        notifRefHandleChildAdded = NOTIFICATIONS_REF
            .child(currentUid)
            .observe(.childAdded) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                            
                let typeSnapshot = allObjects.filter({ $0.key == "type" }).first
                let valueType = typeSnapshot?.value as? Int ?? 0
                
                // Handle the on message notif type.
                if valueType != 3 {
                    allObjects.forEach { (snapshot) in
                        let key = snapshot.key
                        let val = snapshot.value as? Int
                        
                        if key == "checked" {
                            self.dot.isHidden = val == 1
                        }
                    }
                }
            }
    }
    
    /// Checks if we are ought to proceed to hiding the dot navBar notif.
    private func setDotNotifToHiddenIfPossibleForChatController(userIdFromNotification: String, appNotif: AppNotif) {
        if appNotif.didCheck == false,
           appNotif.notificationType == .Message {
            
            if UIViewController.current() is ChatController,
               let chatCon = UIViewController.current() as? ChatController,
               let currentChatmate = chatCon.user?.uid {
                // Notification came from the current chat partner of the current user
                // Set the dot to hidden. Don't show notif either.
                if userIdFromNotification == currentChatmate {
                    self.dot.isHidden = true
                } else {
                    // Notification came from someone else.
                    // Show the dot, and show the notif.
                    self.dot.isHidden = false
                }
            } else {
                self.dot.isHidden = false
            }
            
            return
        }
        
        
    }
}
