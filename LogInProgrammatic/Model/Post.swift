//
//  Post.swift
//  LogInProgrammatic
//
//  Created by Mac on 10/24/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    struct PostImage {
        var key: String = ""
        var imageUrl: String = ""
        
        init(key: String, dictionary: [String : Any]) {
            self.key = key
            
            if let imageUrl = dictionary["imageUrl"] as? String {
                self.imageUrl = imageUrl
            }
        }
    }
    
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    /// The owner
    var user: User?
    var didLike = false
    
    var images: [PostImage]?
    
    private var postRefHandle: DatabaseHandle?
    
    init(postId: String!, user: User?, dictionary: Dictionary<String, AnyObject>) {
        self.postId = postId
        self.user = user
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let imagesDic = dictionary["images"] as? [String: Any] {
            var newImages = [PostImage]()
            
            imagesDic.forEach { (dic) in
                newImages.append(PostImage(key: dic.key, dictionary: dic.value as! [String : Any]))
            }
            
            self.images = newImages
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        
        if addLike {
            
            // updates user-likes structure
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1]) { (err, ref) in
                // send notification to server
                self.sendLikeNotificationToServer()
                
                // updates post-likes structure
                POST_LIKES_REF.child(postId).updateChildValues([currentUid: 1]) { (err, ref) in
                    self.likes = self.likes + 1
                    self.didLike = true
                    POSTS_REF.child(postId).child("likes").setValue(self.likes)
                    completion(self.likes)
                }
            }
        } else {
            // unlikes another user's post
            // observes database for notification id to remove
            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value) { (snapshot) in
                // notification id to remove from server
                if let notificationID = snapshot.value as? String {
                    // remove notification from server
                    NOTIFICATIONS_REF.child(self.ownerUid).child(notificationID).removeValue { (err, ref) in
                        self.removeLike { (likes) in
                            completion(likes)
                        }
                    }
                } else {
                    // unlikes the user's own post
                    self.removeLike { (likes) in
                        completion(likes)
                    }
                }
            }
        }
    }
    
    
    func removeLike(withCompletion completion: @escaping (Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // removes like from user-like structure
        USER_LIKES_REF.child(currentUid).child(postId).removeValue { (err, ref) in
            // removes like from post-like structure
            POST_LIKES_REF.child(self.postId).child(currentUid).removeValue { (err, ref) in
                guard self.likes > 0 else { return }
                self.likes = self.likes - 1
                self.didLike = false
                POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                completion(self.likes)
            }
        }
    }
    
    func deletePost() {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let postId = postId else { return }
        
        images?.forEach({ (image) in
            if image.imageUrl != "" {
                Storage.storage()
                    .reference(forURL: image.imageUrl)
                    .delete(completion: nil)
            }
        })
        
        USER_FOLLOWER_REF.child(currentUid).observeSingleEvent(of: .childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).child(self.postId).removeValue()
        }
        
        USER_FEED_REF.child(currentUid).child(postId).removeValue()
        
        USER_POSTS_REF.child(currentUid).child(postId).removeValue()
        
        postRefHandle = POST_LIKES_REF
            .child(postId)
            .observe(.childAdded) { (snapshot) in
                let uid = snapshot.key
                
                POST_LIKES_REF.child(postId)
                    .removeObserver(withHandle: self.postRefHandle!)
                
                USER_LIKES_REF.child(uid).child(self.postId).observeSingleEvent(of: .value) { (snapshot) in
                    guard let notificationId = snapshot.value as? String else { return }
                    
                    NOTIFICATIONS_REF.child(self.ownerUid).child(notificationId).removeValue { (err, ref) in
                        
                        POST_LIKES_REF.child(self.postId).removeValue()
                        
                        USER_LIKES_REF.child(uid).child(self.postId).removeValue()
                    }
                }
            }
        
        COMMENT_REF.child(postId).removeValue()
        
        POSTS_REF.child(postId).removeValue()
    }
    
    func sendLikeNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        //guard let postId = postId else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        if currentUid != self.ownerUid {
            
            // notification values
            let values = ["checked": 0,
                          "creationDate": creationDate,
                          "uid": currentUid,
                          "type": LIKE_INT_VALUE,
                          "postId": postId] as [String : Any]
            
            // notification database reference
            let notificationRef = NOTIFICATIONS_REF.child(self.ownerUid).childByAutoId()
            
            // upload notification values to database
            notificationRef.updateChildValues(values) { (err, ref) in
                USER_LIKES_REF.child(currentUid).child(self.postId).setValue(notificationRef.key)
            }
        }
        
    }
    
}
