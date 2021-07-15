//
//  FeedVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/14/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

private let reuseIdentifier = "Cell"
public let tabBarNotificationKey = NSNotification.Name(rawValue: "tabBarNotificationKey")
public let newPostSuccessNotificationKey = NSNotification.Name(rawValue: "newPostSuccessNotificationKey")
public let deletePostNotificationKey = NSNotification.Name(rawValue: "deletePostNotificationKey")
public let tappedPostCellImageNotificationKey = NSNotification.Name(rawValue: "tappedPostCellImageNotificationKey")

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
    
    //MARK: - Properties
    
    private var prevScrollDirection: CGFloat = 0
    
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    var currentKey: String?
    var userProfileController: UserProfileVC?
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36)
        label.textColor = .black
        label.text = "Feed"
        return label
    }()
    
    // MARK: - Init
    
    deinit {
        print("FeedVC deallocated! ✅")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewSinglePost {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        } else {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset.bottom = 60
        
        // register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // configure refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        fetchPosts()
        addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func addObserver() { }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width + 78
        return CGSize(width: width, height: height)
    }

    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewSinglePost {
            return 1
        } else {
            return posts.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.delegate = self
        
        if viewSinglePost {
            if let post = self.post {
                cell.post = post
            }
        } else {
            cell.post = posts[indexPath.item]
        }
        
        return cell
    }

    //MARK: - FeedCellDelegate Protocol
    
    func handleFullnameTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = post.user
        userProfileVC.fromTabBar = false
        
        navigationController?.pushViewController(userProfileVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        
        if post.ownerUid == Auth.auth().currentUser?.uid {
            let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) in
                
                post.deletePost()

                if let userProfileController = self.userProfileController {
                    _ = self.navigationController?.popViewController(animated: true)
                    userProfileController.handleRefresh()
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            
        } else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // Report Post
            alertController.addAction(UIAlertAction(title: "Report", style: .default, handler: { (_) in
                
                guard let postId = post.postId else { return }
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let creationDate = Int(NSDate().timeIntervalSince1970)
                
                let values = ["creationDate": creationDate,
                              "uid": uid] as [String : Any]
                
                REPORT_REF.child(postId).childByAutoId().updateChildValues(values)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func handleReport() {
        guard let postId = self.post?.postId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["creationDate": creationDate,
                      "uid": uid] as [String : Any]
        REPORT_REF.child(postId).childByAutoId().updateChildValues(values)
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
                //cell.likeButton.setImage(#imageLiteral(resourceName: "heart_unfilled"), for: .normal)
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
                //cell.likeButton.setImage(#imageLiteral(resourceName: "heart_filled"), for: .normal)
                cell.likeButton.isEnabled = true
            }
        }
    }
    
    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postID = post.postId else { return }
        guard let likes = post.likes else { return }
        
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeVC.postID = postID
        
        if likes != 0 {
            navigationController?.pushViewController(followLikeVC, animated: true)
            navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "",
                style: .plain,
                target: self,
                action: #selector(popToPrevious)
            )
        }
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            // check if post id exists in user like structure
            if snapshot.hasChild(postId) {
                post.didLike = true
                //cell.likeButton.setImage(#imageLiteral(resourceName: "heart_filled"), for: .normal)
            } else {
                post.didLike = false
                //cell.likeButton.setImage(#imageLiteral(resourceName: "heart_unfilled"), for: .normal)
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
    
    //MARK: - Handlers
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView.reloadData()
    }
    
    // function to dismiss/present the TabBar when scrolling up or down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollViewY = scrollView.contentOffset.y
        let scrollSizeHeight = scrollView.contentSize.height
        let scrollFrameHeight = scrollView.frame.height
        let scrollHeight = scrollSizeHeight - scrollFrameHeight
        var isHidden = false
        
        if prevScrollDirection > scrollViewY && prevScrollDirection < scrollHeight {
            isHidden = false
        } else if prevScrollDirection < scrollViewY && scrollViewY > 0 {
            isHidden = true
        }
        
        let userInfo : [String : Bool] = ["isHidden" : isHidden]
        NotificationCenter.default.post(name: tabBarNotificationKey, object: nil, userInfo: userInfo)
        prevScrollDirection = scrollView.contentOffset.y
    }
    
    // MARK: - API
    
    /// The function below updates the Home Feed of the current user with posts from all users, to create a 'Global Feed.'
    func fetchPosts() {
        if currentKey == nil {
            POSTS_REF.queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in

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
            POSTS_REF.queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { (snapshot) in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }

                allObjects.forEach { (snapshot) in
                    let postId = snapshot.key
                    if snapshot.key != self.currentKey {
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
}
