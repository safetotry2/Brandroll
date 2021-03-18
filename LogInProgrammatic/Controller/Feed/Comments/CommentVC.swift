//
//  CommentVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/2/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

private let reuseIdentifier = "CommentCell"

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CommentCellDelegate {
    
    // MARK: - Properties
    
    var comments = [Comment]()
    var post: Post?
    
    private var commentsRefHandle: DatabaseHandle?
    
    lazy var containerView: CommentInputAccessoryView = {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        let containerView = CommentInputAccessoryView(frame: frame)
        containerView.backgroundColor = .white
        containerView.delegate = self
        return containerView
    }()
    
    // test
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width
        layout.estimatedItemSize = CGSize(width: width, height: 10)
        return layout
    }()
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation title
        navigationItem.title = "Comments"
                
        // configure collectionView
        configureCollectionView()
                
        // register cell class
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // configure layout
        //collectionView.collectionViewLayout = layout
        
        // fetch comments
        fetchComments()
        
        // configure keyboard observers
        configureKeyboardObserver()
        configureKeyboardObserverAfterPost()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

        removeObserver()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func removeObserver() {
        guard let postId = post?.postId,
              let commentsRefHandle = commentsRefHandle else { return }
        
        COMMENT_REF
            .child(postId)
            .removeObserver(withHandle: commentsRefHandle)
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // test
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
        super.traitCollectionDidChange(previousTraitCollection)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
        layout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: - Handlers
    
    func handleFullnameTapped(for cell: CommentCell) {
        guard let comment = cell.comment else { return }
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = comment.user
        userProfileVC.fromTabBar = false
        
        navigationController?.pushViewController(userProfileVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleKeyboardDidShow() {
        scrollToBottom()
    }
    
    @objc func handleKeyboardDidDisappear() {
        scrollToBottomWithoutAnimation()
    }
    
    func scrollToBottom() {
        if comments.count > 0 {
            let indexPath = IndexPath(item: comments.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func scrollToBottomWithoutAnimation() {
        if comments.count > 0 {
            let indexPath = IndexPath(item: comments.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func configureKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UITextView.textDidBeginEditingNotification, object: nil)
    }
    
    func configureKeyboardObserverAfterPost() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidDisappear), name: UITextView.keyboardDidHideNotification, object: nil)
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 40, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - API
    
    func fetchComments() {
        guard let postId = post?.postId else { return }
        
        commentsRefHandle = COMMENT_REF
            .child(postId)
            .observe(.childAdded) { (snapshot) in
                
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                Database.fetchUser(with: uid) { (user) in
                    
                    let comment = Comment(user: user, dictionary: dictionary)
                    self.comments.append(comment)
                    self.collectionView.reloadData()
                }
            }
    }
    
    func uploadCommentNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.post?.postId else { return }
        guard let uid = post?.user?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // notification values
        let values = ["checked": 0,
        "creationDate": creationDate,
        "uid": currentUid,
        "type": COMMENT_INT_VALUE,
        "postId": postId]  as [String : Any]
        
        // upload notification to server
        if uid != currentUid {
            NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values)
        }
    }
    
}


extension CommentVC: CommentInputAccessoryViewDelegate {
    
    func didSubmit(forComment comment: String) {
        guard let postId = self.post?.postId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": comment,
                      "creationDate": creationDate,
                      "uid": uid] as [String : Any]
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            self.uploadCommentNotificationToServer()
        }
        
        self.containerView.clearCommentTextView()
        self.containerView.commentTextView.resignFirstResponder()
    }
}
