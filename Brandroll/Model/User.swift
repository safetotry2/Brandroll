//
//  User.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/23/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//
import Firebase

class User {
    
    // attributes
    var username: String!
    var name: String!
    var occupation: String!
    
    var bio: String!
    
    var profileImageUrl: String!
    var uid: String!
    var isFollowed = false
    
    var usersPostRefHandle: DatabaseHandle?
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.uid = uid
        
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let occupation = dictionary["occupation"] as? String {
            self.occupation = occupation
        }
        
        
        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
        
    }
    
    func follow(completion: EmptyCallBack? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uid = uid else { return }
        
        // add followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        // add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid: 1])
        
        // upload follow notification to server
        uploadFollowNotificaitonToServer()
        
        // add followed users posts to current user feed
        USER_POSTS_REF
            .child(self.uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.isFollowed = true
                
                if snapshot.value == nil || snapshot.value is NSNull {
                    completion?()
                    return
                }
                
                if let postsDic = snapshot.value as? [String : Any] {
                    for post in postsDic {
                        let postId = post.key
                        
                        USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
                    }
                }
                
                completion?()
            })
    }
    
    func unfollow(completion: EmptyCallBack? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uid = uid else { return }
        
        // remove followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()

        // remove current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()
        
        // remove unfollowed users posts from current user-feed
        USER_POSTS_REF
            .child(self.uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.isFollowed = false
                
                if snapshot.value == nil || snapshot.value is NSNull {
                    completion?()
                    return
                }
                
                if let postsDic = snapshot.value as? [String : Any] {
                    for post in postsDic {
                        let postId = post.key
                        
                        USER_FEED_REF.child(currentUid).child(postId).removeValue()
                    }
                }
                
                completion?()
            })
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) ->()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(self.uid) {
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
    }
    
    func uploadFollowNotificaitonToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // notification values
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": FOLLOW_INT_VALUE,] as [String : Any]
        
        NOTIFICATIONS_REF.child(self.uid).childByAutoId().updateChildValues(values)
    }
    
}
