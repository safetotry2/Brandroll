//
//  CreateTitleVC.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 3/2/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import DKImagePickerController
import Firebase
import SVProgressHUD
import UIKit

class CreateTitleVC: UIViewController {
    
    // MARK: - Properties
    
    var imageAssets: [DKAsset] = []
    
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
            imageAssets.count > 0,
            let caption = textField.text,
            let currentUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let imagesData = imageAssets.compactMap { $0.image?.jpegData(compressionQuality: 0.7) }
        
        guard imagesData.count > 0 else { return }
        
        // create date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // post data
        let values = ["caption": caption,
                      "creationDate": creationDate,
                      "likes": 0,
                      "ownerUid": currentUid] as [String: Any]
        
        // post id
        let postId = POSTS_REF.childByAutoId()
        
        // upload information to database
        SVProgressHUD.show()
        postId.updateChildValues(values) { (err, ref) in
            SVProgressHUD.dismiss {
                guard let postKey = postId.key else { return }
                
                // update user-posts structure
                USER_POSTS_REF.child(currentUid).updateChildValues([postKey: 1])
                
                // update user-feed structure
                self.updateUserFeeds(with: postKey)
                
                // continue the uploads.
                self.uploadAssetsToPostWithKey(postKey, imagesData: imagesData)
            }
        }
    }
    
    private func uploadAssetsToPostWithKey(_ postKey: String, imagesData: Array<Data>) {
        SVProgressHUD.show(withStatus: "Uploading...")
        
        let group = DispatchGroup()
        var error: Error?
        
        func upload(_ imageData: Data) {
            let filename = NSUUID().uuidString
            let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                
                // handle error
                if let error = error {
                    print("Failed to upload image to storage with error", error.localizedDescription)
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    guard let imageURL = url?.absoluteString else { return }
                    
                }
            }
        }
        
        for data in imagesData {
            group.enter()
            
            upload(data)
        }
    }
    
    private func returnToNewsFeed() {
        dismiss(animated: true, completion: {
            self.tabBarController?.selectedIndex = 0
        })
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

