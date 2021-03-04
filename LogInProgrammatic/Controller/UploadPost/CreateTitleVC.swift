//
//  CreateTitleVC.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 3/2/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import SVProgressHUD
import UIKit

typealias ImageDataTuple = (data: Data, width: CGFloat, height: CGFloat)
typealias UploadedPostImageTuple = (imageUrl: String, width: CGFloat, height: CGFloat)

class CreateTitleVC: UIViewController {
    
    // MARK: - Properties
    
    var images: [UIImage] = []
    
    lazy var containerView: UIView = {
        let cv = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180))
        cv.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        cv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cv.layer.cornerRadius = 12
        return cv
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                                                                    .font: UIFont.boldSystemFont(ofSize: 22.0)])
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        tf.layer.cornerRadius = 8
        tf.setLeftPaddingPoints(7)
        tf.tintColor = UIColor.systemBlue
        tf.textColor = UIColor.black
        tf.font = UIFont.boldSystemFont(ofSize: 22.0)
        tf.keyboardAppearance = .dark
        tf.autocorrectionType = .no
        return tf
    }()
    
    lazy var cancelButton: UIButton = {
        let cb = UIButton(type: .system)
        cb.setTitle("Cancel", for: .normal)
        cb.setTitleColor(.darkGray, for: .normal)
        cb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cb.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        cb.layer.borderWidth = 1
        cb.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        cb.layer.cornerRadius = 8
        cb.addTarget(self, action: #selector(handleCancelTapped), for: .touchUpInside)
        return cb
    }()
    
    lazy var postButton: UIButton = {
        let pb = UIButton(type: .system)
        pb.setTitle("Post", for: .normal)
        pb.setTitleColor(.white, for: .normal)
        pb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        pb.backgroundColor = UIColor.systemBlue.withAlphaComponent(1.0)
        pb.layer.cornerRadius = 8
        pb.addTarget(self, action: #selector(handlePostTapped), for: .touchUpInside)
        return pb
    }()
    
    // MARK: - Functions
    // MARK: Overrides
    
    deinit {
        print("Create title deallocated! ✅")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        addOverlayBlurredBackgroundView()
    }
    
    // MARK: - Handlers
    
    @objc func handleCancelTapped() {
        self.dismiss(animated: true, completion: nil)
        textField.inputAccessoryView?.removeFromSuperview()
    }
    
    @objc func handlePostTapped() {
        beginUploadAndPost()
    }
    
    func configureViewComponents() {
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        containerView.addSubview(textField)
        textField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 35, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 50)
        
        containerView.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 30, paddingBottom: 30, paddingRight: 0, width: 0, height: 45)
        
        containerView.addSubview(postButton)
        postButton.anchor(top: nil, left: cancelButton.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 30, paddingRight: 30, width: 0, height: 45)
        
        cancelButton.widthAnchor.constraint(equalTo: postButton.widthAnchor).isActive = true
        
        textField.inputAccessoryView = containerView
        textField.becomeFirstResponder()
    }
    
    func addOverlayBlurredBackgroundView() {
        let blurView = UIVisualEffectView()
        blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        
        self.view.addSubview(blurView)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
        blurView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
        blurView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
    }
}

// MARK: - API & Posting

extension CreateTitleVC {
    func updateUserFeeds(with postId: String) {
        // current user id
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // database values
        let values = [postId: 1]
        
        // update follower feeds
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            USER_FOLLOWER_REF.child(currentUid).removeAllObservers()
            
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        
        // update current user feed
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
    
    /**
     Creates a post first, and then upload all the assets, finally update the post images node.
     */
    func beginUploadAndPost() {
        // parameters
        guard
            images.count > 0,
            let caption = textField.text,
            let currentUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let imagesData = images.compactMap { (image) -> ImageDataTuple? in
            if let data = image.jpegData(compressionQuality: 0.5) {
                return ImageDataTuple(data: data, width: image.size.width, height: image.size.height)
            } else {
                return nil
            }
        }
            
        guard imagesData.count > 0 else { return }
        
        var imagesLeft = imagesData.count
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.isHidden = true
            self.textField.resignFirstResponder()
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        let group = DispatchGroup()
        var uploadedImageTuples = Array<UploadedPostImageTuple>()
        
        func updateLoader() {
            let noun = imagesLeft == 1 ? "photo" : "photos"
            SVProgressHUD.show(withStatus: "\(imagesLeft) \(noun) remaining")
        }
        
        updateLoader()
        
        func upload(_ tuple: ImageDataTuple, index: Int) {
            let filename = NSUUID().uuidString
            let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
            
            let uploadtask = storageRef.putData(tuple.data, metadata: nil) { (metadata, uploadError) in
                storageRef.downloadURL { (url, urlError) in
                    let urlString = url?.absoluteString ?? ""
                    let newTuple: UploadedPostImageTuple = UploadedPostImageTuple(imageUrl: urlString, width: tuple.width, height: tuple.height)
                    uploadedImageTuples.append(newTuple)
                    group.leave()
                    imagesLeft -= 1
                }
            }
            
            uploadtask.observe(.success) { _ in
                updateLoader()
            }
            
            uploadtask.observe(.failure) { _ in
                updateLoader()
            }
        }
        
        for (index, data) in imagesData.enumerated() {
            group.enter()
            upload(data, index: index)
        }
        
        group.notify(queue: .main) { [self] in
            post(caption, userId: currentUid, uploadedImageTuples: uploadedImageTuples)
        }
    }
    
    private func post(_ caption: String, userId: String, uploadedImageTuples: Array<UploadedPostImageTuple>) {
        // create date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // post id
        let postId = POSTS_REF.childByAutoId()
        
        var imageDic: [String : Any] = [:]
        
        uploadedImageTuples.forEach { (tuple) in
            guard let imageKey = postId
                    .child("images")
                    .childByAutoId()
                    .key else { return }
            
            imageDic[imageKey] = [
                "imageUrl" : tuple.imageUrl,
                "width" : tuple.width,
                "height" : tuple.height
            ]
        }
        
        // post data
        let values = [
            "caption": caption,
            "creationDate": creationDate,
            "likes": 0,
            "ownerUid": userId,
            "images": imageDic
        ] as [String: Any]
        
        // upload information to database
        SVProgressHUD.show(withStatus: "Posting...")
        postId.updateChildValues(values) { (err, ref) in
            SVProgressHUD.dismiss {
                let postKey = postId.key ?? ""
                
                // update user-posts structure
                USER_POSTS_REF.child(userId).updateChildValues([postKey: 1])
                
                // update user-feed structure
                self.updateUserFeeds(with: postKey)
                
                self.returnToNewsFeed()
            }
        }
    }
    
    private func returnToNewsFeed() {
        NotificationCenter.default.post(name: newPostSuccessNotificationKey, object: nil)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

