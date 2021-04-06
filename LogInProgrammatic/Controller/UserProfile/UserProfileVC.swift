//
//  UserProfileVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/14/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate, UserProfileHeaderDelegate {
    
    // MARK: - Properties
    
    var user: User?
    var posts = [Post]()
    var currentKey: String?
    var fromTabBar = true
    
    private var followingRefHandle: DatabaseHandle?
    private var followersRefHandle: DatabaseHandle?
    
    // MARK: - Init

    deinit {
        print("UserProfileVC deallocated! 🐶")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true

        self.collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        
        // Register cell classes
        self.collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        // configure navigation bar
        if fromTabBar {
            configureNavigationBar()
        }
        
        // configure refresh control
        configureRefreshControl()
        
        // fetch user data
        if self.user == nil {
            fetchCurrentUserData()
        }
        
        // fetch posts
        fetchPosts()
    }
    
    
    
    /**
     Remove the observers. Called by tabBarController.
     We don't need to call this from viewWillDisappear since this controller
     is ought to retain itself as part of the tab controller.
     */
    func removeObserver() {
        guard let uid = user?.uid,
              let followersRefHandle = followersRefHandle,
              let followingRefHandle = followingRefHandle else { return }
        
        USER_FOLLOWER_REF
            .child(uid)
            .removeObserver(withHandle: followersRefHandle)
        
        USER_FOLLOWING_REF
            .child(uid)
            .removeObserver(withHandle: followingRefHandle)
    }

    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        let height = width + 78
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 160)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    
    // MARK: - UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader

        // set delegate
        header.delegate = self

        // set the user in header
        header.user = self.user
        navigationItem.title = user?.name

        // return header
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.delegate = self
        cell.post = posts[indexPath.item]
        return cell
    }

    //MARK: - UserProfileHeader Protocol
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 1)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 0)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    func handleEditProfileTapped(for header: UserProfileHeader) {

        let editProfileController = EditProfileController()
        editProfileController.user = user
        editProfileController.userProfileController = self
        let navigationController = UINavigationController(rootViewController: editProfileController)
        navigationController.modalPresentationStyle = .automatic

        present(navigationController, animated: true, completion: nil)
    }
    
    func handleFollowButtonTapped(for header: UserProfileHeader) {
        guard let user = header.user else { return }

        if header.followButton.titleLabel?.text == "Follow" {
            header.followButton.setTitle("Following", for: .normal)
            user.follow()
        } else {
            header.followButton.setTitle("Follow", for: .normal)
            user.unfollow()
        }
    }
    
    func handleMessageTapped(for header: UserProfileHeader) {
        print("Handle message tapped")
    }
    
    func setUserStats(for header: UserProfileHeader) {
        guard let uid = header.user?.uid else { return }
        
        var numberOfFollowers: Int!
        var numberOfFollowing: Int!
        
        // get number of followers
        followersRefHandle = USER_FOLLOWER_REF
            .child(uid)
            .observe(.value) { (snapshot) in
                if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                    numberOfFollowers = snapshot.count
                } else {
                    numberOfFollowers = 0
                }
                
                let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16)])
                attributedText.append(NSAttributedString(string: " Followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black]))
                
                header.followersLabel.attributedText = attributedText
            }
        
        // get number of following
        followingRefHandle = USER_FOLLOWING_REF
            .child(uid)
            .observe(.value) { (snapshot) in
                if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                    numberOfFollowing = snapshot.count
                } else {
                    numberOfFollowing = 0
                }
                
                let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16)])
                attributedText.append(NSAttributedString(string: " Following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black]))
                
                header.followingLabel.attributedText = attributedText
            }
        
    }
    
    // MARK: - FeedCellDelegate Protocol
    
    func handleFullnameTapped(for cell: FeedCell) {
        // The fullnameButton is disabled in a user's profile.
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        
        if post.ownerUid == Auth.auth().currentUser?.uid {
            let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) in
                post.deletePost()
                self.handleRefresh()
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func handleLikeTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        
        if post.didLike {
            // handle unlike post
            cell.likeButton.isEnabled = false
            post.adjustLikes(addLike: false) { (likes) in
                if likes == 1 {
                    cell.likeLabel.text = "\(likes) like"
                } else {
                    cell.likeLabel.text = "\(likes) likes"
                }
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                cell.likeButton.isEnabled = true
            }
        } else {
            // handle like post
            cell.likeButton.isEnabled = false
            post.adjustLikes(addLike: true) { (likes) in
                if likes == 1 {
                    cell.likeLabel.text = "\(likes) like"
                } else {
                    cell.likeLabel.text = "\(likes) likes"
                }
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                cell.likeButton.isEnabled = true
            }
        }
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
        navigationController?.pushViewController(commentVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            // check if post id exists in user like structure
            if snapshot.hasChild(postId) {
                post.didLike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            } else {
                post.didLike = false
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected-1"), for: .normal)
            }
        }
    }
    
    func handleShowLikes(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        guard let postID = post.postId else { return }
        
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeVC.postID = postID
        navigationController?.pushViewController(followLikeVC, animated: true)
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
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView.reloadData()
    }
    
    @objc func handleLogout() {
        // declare alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add alert logout action
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                // handle logout from tabController
                if let tabBarController = self.tabBarController as? MainTabVC {
                    tabBarController.logout()
                }
                
                // attempt sign out
                try Auth.auth().signOut()
                print("Successfully logged out user")
                
            } catch {
                // handle error
                print("Failed to sign out")
            }
        }))
        
        // add cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func configureNavigationBar() {
        //guard let user = self.user else { return }
        //guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        //navigationItem.title = user?.name
        //navigationController?.navigationBar.prefersLargeTitles = true

    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    // MARK: - API
    
    func fetchPosts() {
        
        var uid: String!
        
        if let user = self.user {
            uid = user.uid
        } else {
            uid = Auth.auth().currentUser?.uid
        }
        
        // initial data pull
        if currentKey == nil {
            
            USER_POSTS_REF.child(uid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                
                self.collectionView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                }
                self.currentKey = first.key
            }
        } else {
            
            USER_POSTS_REF.child(uid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let postId = snapshot.key
                    
                    if postId != self.currentKey {
                        self.fetchPost(withPostId: postId)
                    }
                }
                self.currentKey = first.key
            }
            
        }
    }
    
    func fetchPost(withPostId postId: String) {
        
        Database.fetchPost(with: postId) { (post) in
            
            self.posts.append(post)
            
            self.posts.sort { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            }
            self.collectionView.reloadData()
        }
    }

    func fetchCurrentUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        DB_REF.child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
        
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.user = user
            //self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }
        
   
    }

}
