//
//  MainTabVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/13/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import DKImagePickerController
import Firebase
import FirebaseAuth
import UIKit

let hasNotch = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20

class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Properties
    
    let dot = UIView()
    var notificationIDs = [String]()
    
    private var images: [UIImage] = []
    private var imageAssets: [DKAsset] = []
    
    private var notifRefHandle: DatabaseHandle?
    private var notifRefHandleChildAdded: DatabaseHandle?
    
    private (set)var feedVC: FeedVC!
    private (set)var searchVC: SearchVC!
    private (set)var notificationsVC: NotificationsVC!
    private (set)var userProfileVC: UserProfileVC!
    
    private (set)var previewVC: PreviewUploadVC?
    
    private var uiDelegate = CustomUIDelegate()
    
    // MARK: - Functions
    // MARK: Overrides
    
    deinit {
        print("Main flow deallocated! ✅")
    }
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tappedPostCellImage(_:)), name: tappedPostCellImageNotificationKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.tappedPostCellImageTwice(_:)), name: tappedPostCellImageTwiceNotificationKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newPostSuccess(_:)), name: newPostSuccessNotificationKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deletePost(_:)), name: deletePostNotificationKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: tabBarNotificationKey, object: nil)        
    }
    
    // MARK: - Handlers
    
    @objc func tappedPostCellImage(_ notification: Notification) {
        guard let postImages = notification.object as? Array<Post.PostImage> else { return }
        showPreview(postImages)
    }
    
    @objc func tappedPostCellImageTwice(_ notification: Notification) {
        print("handle post tapped twice")
        guard let post = notification.object else { return }
        
    }
    
    @objc func newPostSuccess(_ notification: Notification) {
        weak var weakSelf = self
        
        imageAssets.removeAll()
        images.removeAll(keepingCapacity: false)
        
        DispatchQueue.main.async {
            self.previewVC?.presentedViewController?.dismiss(animated: false, completion: {
                weakSelf?.previewVC?.dismiss(animated: false, completion: {
                    weakSelf?.previewVC = nil
                    weakSelf?.feedVC.handleRefresh()
                    weakSelf?.userProfileVC.handleRefresh()
                    weakSelf?.selectedIndex = 0
                })
            })
        }
    }
    
    @objc func deletePost(_ notification: Notification) {
        guard let post = notification.object as? Post else { return }
        feedVC.handleRefresh()
        notificationsVC.removeNotifByPost(post)
        userProfileVC.handleRefresh()
    }
    
    @objc func notificationReceived(_ notification: Foundation.Notification) {
        guard let isHidden = notification.userInfo?["isHidden"] as? Bool else { return }
        self.setTabBar(hidden: isHidden)
    }
    
    // function to create view controllers that exist within the tab bar
    func configureViewControllers() {
        
        // home feed controller
        feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        let feedNavCon = constructNavController(unselectedImage: #imageLiteral(resourceName: "house_unselected"), selectedImage: #imageLiteral(resourceName: "house_selected"), rootViewController: feedVC)
        
        // search feed controller
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        searchVC = SearchVC(collectionViewLayout: layout)
        let searchNavCon = constructNavController(unselectedImage: #imageLiteral(resourceName: "magnifier_unselected"), selectedImage: #imageLiteral(resourceName: "magnifier_selected"), rootViewController: searchVC)
        
        // select image controller
        let selectImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "add_button_unselected"), selectedImage: #imageLiteral(resourceName: "add_button_unselected"))
        
        // notification controller
        notificationsVC = NotificationsVC()
        let notificationsNavCon = constructNavController(unselectedImage: #imageLiteral(resourceName: "bell_unselected"), selectedImage: #imageLiteral(resourceName: "bell_selected"), rootViewController: notificationsVC)
        
        // profile controller
        userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        let userProfileNavCon = constructNavController(unselectedImage: #imageLiteral(resourceName: "person_unselected"), selectedImage: #imageLiteral(resourceName: "person_selected"), rootViewController: userProfileVC)
        
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
        let navController = BaseNavCon(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.title = ""
        navController.navigationBar.tintColor = .black
        
        // return nav controller
        return navController
    }
    
    func configureNotificationDot() {
        if let notifTabBarItem = self.tabBar.items![3].value(forKey: "view") as? UIView {
            dot.isHidden = true
            dot.layer.cornerRadius = 3
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
                        
            tabBar.addSubview(dot)
            dot.snp.makeConstraints {
                $0.width.height.equalTo(6)
                $0.centerX.equalTo(notifTabBarItem)
                
                if hasNotch {
                    $0.top.equalTo(notifTabBarItem.snp.bottom).offset(-5)
                } else {
                    $0.bottom.equalTo(notifTabBarItem).offset(-3)
                }
            }
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            showImagePicker()
            return false
        } else if index == 3 {
            dot.isHidden = true
            return true
        }
        
        viewController.tabBarItem.title = ""
        
        return true
    }
    
    // MARK: - Public
    
    func logout() {
        removeChats()
        removeObserver()
        
        // Inform RootVC.
        NotificationCenter.default.post(
            name: RootVC.didLogoutNotification,
            object: nil
        )
    }
    
    func removeChats() {
        MessagesController.messages.removeAll()
        MessagesController.messagesDictionary.removeAll()
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
        
        // Remove observer from self.
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
        
        // Remove observer from the feeds vc.
        feedVC.removeObserver()
        
        // Remove observer from the notifs vc.
        notificationsVC.removeObserver()
        
        // Remove observer from the user profile tab
        userProfileVC.removeObserver()
    }
    
    // MARK: - API
    
    private func observeNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.notificationIDs.removeAll()
        
        self.dot.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
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
    
    @objc func applicationWillEnterForeground() {
        print("applicationWillEnterForeground")
        feedVC.handleRefresh()
        searchVC.handleRefresh()
    }
    
    /// Checks if we are ought to proceed to hiding the dot navBar notif.
    private func setDotNotifToHiddenIfPossibleForChatController(userIdFromNotification: String, appNotif: AppNotif) {
        if appNotif.didCheck == false,
           appNotif.notificationType == .message {
            
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

// MARK: - ShowPickerDelegate

extension MainTabVC: ShowPickerDelegate {
    func showImagePicker() {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos
        pickerController.sourceType = .photo
        pickerController.allowMultipleTypes = false
        pickerController.showsCancelButton = true
        pickerController.maxSelectableCount = 24
        pickerController.select(assets: imageAssets)
        pickerController.UIDelegate = uiDelegate
        pickerController.modalPresentationStyle = .fullScreen
        pickerController.navigationBar.tintColor = UIColor.black
        pickerController.navigationBar.barTintColor = UIColor.white
        pickerController.navigationBar.setValue(true, forKey: "hidesShadow")
        pickerController.view.backgroundColor = .white
        
        present(pickerController, animated: true, completion: nil)
        
        weak var weakSelf = self
        pickerController.didCancel = {
            weakSelf?.imageAssets.removeAll()
            weakSelf?.images.removeAll(keepingCapacity: false)
            pickerController.dismiss(animated: true, completion: nil)
        }
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            weakSelf?.imageAssets = assets
            weakSelf?.images.removeAll(keepingCapacity: false)
            var count = 0
            for asset in assets {
                asset.fetchOriginalImage(completeBlock: {(image, info) in
                    if let image = image {
                        weakSelf?.images.append(image)
                    }
                    count += 1
                    if count == assets.count {
                        weakSelf?.showPreview()
                    }
                })
            }
        }
    }
    
    private func showPreview(_ postImages: Array<Post.PostImage>? = nil) {
        previewVC = PreviewUploadVC()
    
        if postImages != nil {
            previewVC?.postImages = postImages
        } else {
            previewVC?.images = images
        }
        
        previewVC?.delegate = self
        let navigationVC = BaseNavCon(
            rootViewController: previewVC!,
            statusBarShouldBeHidden: true,
            statusBarAnimationStyle: .slide
        )
        
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true, completion: nil)
    }
}
