//
//  NotificationsVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/14/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

private let reuseIdentifier = "NotificationCell"

class NotificationsVC: UITableViewController, NotitificationCellDelegate {
    
    // MARK: - Properties
    
    var timer: Timer?
    var currentKey: String?
    
    var notifications = [AppNotif]()
    
    private var messagesUtils: MessagesUtils?
    
    private let sendBarButtonDot = UIView()
    private lazy var sendBarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        button.addTarget(self, action: #selector(handleShowMessages), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Functions
    
    deinit {
        print("NotificationsVC deallocated! 🐱")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // clear separator lines
        tableView.separatorColor = .clear

        // configure nav bar
        configureNavigationBar()

        // register cell class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)

        messagesUtils = MessagesUtils()
        
        // fetch notifications
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkSeenMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setAllNotifToViewed()
    }
    
    private func checkSeenMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        func continueCheckingSeenMessages() {
            if Thread.isMainThread {
                let areAllMessagesSeen = messagesUtils?.messages.filter {
                    $0.seen == 0 && $0.fromId != currentUid
                }.count == 0
                sendBarButtonDot.isHidden = areAllMessagesSeen
            } else {
                DispatchQueue.main.async {
                    continueCheckingSeenMessages()
                }
            }
        }
        
        messagesUtils?.messages.removeAll()
        messagesUtils?.messagesDictionary.removeAll()
        messagesUtils?.fetchMessages(userId: currentUid) { _ in
            continueCheckingSeenMessages()
        }
    }
    
    private func setAllNotifToViewed() {
        notifications.forEach { (notif) in
            notif.locallyViewed = true
        }
        
        if let tabBarController = self.tabBarController as? MainTabVC {
            tabBarController.dot.isHidden = true
        }
        tableView.reloadData()
    }
    
    func removeObserver() {
        messagesUtils?.removeObserver()
        messagesUtils = nil
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if notifications.count > 4 {
            if indexPath.item == notifications.count - 1 {
                fetchNotifications()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notification = notifications[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        userProfileVC.fromTabBar = false
        navigationController?.pushViewController(userProfileVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    // MARK: - NotificationCellDelegate Protocol
    
    internal func handleFollowTapped(for cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            // handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)
        } else {
            // handle follow user
            user.follow()
            cell.followButton.configure(didFollow: true)
        }
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        
        guard let post = cell.notification?.post else { return }
        
        let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedController.viewSinglePost = true
        feedController.post = post
        navigationController?.pushViewController(feedController, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    // MARK: - Handlers
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
     @objc private func handleShowMessages() {
        let messagesController = MessagesController()
        navigationController?.pushViewController(messagesController, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    private func handleReloadTable() {
        
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false)
    }
    
    @objc private func handleSortNotifications() {
        
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        }
        self.tableView.reloadData()
    }
    
    private func configureNavigationBar() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendBarButton)
        navigationItem.title = "Notifications"
        
        sendBarButtonDot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
        sendBarButtonDot.isHidden = true
        sendBarButtonDot.layer.cornerRadius = 3
        sendBarButtonDot.translatesAutoresizingMaskIntoConstraints = false
        
        sendBarButton.addSubview(sendBarButtonDot)
        NSLayoutConstraint.activate([
            sendBarButtonDot.trailingAnchor.constraint(equalTo: sendBarButton.trailingAnchor),
            sendBarButtonDot.bottomAnchor.constraint(equalTo: sendBarButton.bottomAnchor, constant: 4),
            sendBarButtonDot.widthAnchor.constraint(equalToConstant: 6),
            sendBarButtonDot.heightAnchor.constraint(equalToConstant: 6)
        ])
    }
    
    // MARK: - Public
    
    /// Receives newly observed data from `MainTabVC`.
    /// The parameter `snapshots` contains old notifications.
    func newObservedNotification(_ snapshots: [DataSnapshot]) {
        let unCheckedSnapshots = snapshots.filter { (snapshot) -> Bool in
            if let dictionary = snapshot.value as? Dictionary<String, AnyObject>,
               let checked = dictionary["checked"] as? Int,
               checked == 0 {
                return true
            } else {
                return false
            }
        }
        
        unCheckedSnapshots.forEach { (snapshot) in
            fetchNotifications(withNotificationId: snapshot.key, dataSnapshot: snapshot)
        }
    }
    
    // MARK: - API
    
    private func fetchNotifications(withNotificationId notificationId: String, dataSnapshot snapshot: DataSnapshot) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
        guard let uid = dictionary["uid"] as? String else { return }
        
        Database.fetchUser(with: uid) { (user) in
            
            // if notification is for post
            if let postId = dictionary["postId"] as? String {
                
                Database.fetchPost(with: postId) { (post) in
                    let notification = AppNotif(key: snapshot.key, user: user, post: post, dictionary: dictionary)
                    self.addNewNotification(notification)
                }
            } else {
                let notification = AppNotif(key: snapshot.key, user: user, dictionary: dictionary)
                self.addNewNotification(notification)
            }
        }
        NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
    }
    
    private func addNewNotification(_ notification: AppNotif) {
        if !notifications.contains(where: { $0.key == notification.key }) {
            // BRD1.3
            if notification.notificationType == .Message {
                checkSeenMessages()
                
                // BRD1.2 - prevent notification if current is chat controller.
                // See: `setDotNotifToHiddenIfPossible`.
                if UIViewController.current() is ChatController,
                   let chatCon = UIViewController.current() as? ChatController,
                   let currentChatmate = chatCon.user?.uid {
                    
                    // Notification came from the current chat partner of the current user
                    // Set the dot to hidden. Don't show notif either.
                    if notification.uid == currentChatmate {
                        return
                    }
                }
            }
            
            self.notifications.append(notification)
            self.handleSortNotifications()
            self.handleReloadTable()
        }
    }
    
    private func fetchNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if currentKey == nil {
            NOTIFICATIONS_REF.child(currentUid)
                .queryLimited(toLast: 12)
                .observeSingleEvent(of: .value) { (snapshot) in
                    self.handleNotificationQuerySnapshot(snapshot)
            }
        } else {
            NOTIFICATIONS_REF.child(currentUid)
                .queryOrderedByKey()
                .queryEnding(atValue: self.currentKey)
                .queryLimited(toLast: 13)
                .observeSingleEvent(of: .value) { (snapshot) in
                    self.handleNotificationQuerySnapshot(snapshot)
            }
        }
    }
    
    private func handleNotificationQuerySnapshot(_ snapshot: DataSnapshot) {
        print("handleNotificationQuerySnapshot: \(snapshot)")
        
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
        guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
        
        allObjects.forEach { (snapshot) in
            let notificationId = snapshot.key
            self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
        }
        self.currentKey = first.key
    }
}
