//
//  AppNotif.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/6/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Foundation

class AppNotif {
    
    enum NotificationType: Int, Printable {
        
        case like
        case comment
        case follow
        case message
        
        var description: String {
            switch self {
            case .like: return " liked your post"
            case .comment: return " commented on your post"
            case .follow: return " started following you"
            case .message: return " sent you a message"
            }
        }
        
        init(index: Int) {
            switch index {
            case 0: self = .like
            case 1: self = .comment
            case 2: self = .follow
            case 3: self = .message
            default: self = .like
            }
        }
    }
    
    var key: String!
    var creationDate: Date!
    var uid: String!
    var postId: String?
    var post: Post?
    var user: User?
    var type: Int?
    var notificationType: NotificationType!
    var didCheck = false
    
    init(key: String, user: User?, post: Post? = nil, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        self.user = user
        
        if let post = post {
            self.post = post
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let type = dictionary["type"] as? Int {
            self.notificationType = NotificationType(index: type)
        }
        
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let postId = dictionary["postId"] as? String {
            self.postId = postId
        }
        
        if let checked = dictionary["checked"] as? Int {
            didCheck = checked == 0 ? false : true
        } else {
            didCheck = true
        }
    }
}
