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
        
        case Like
        case Comment
        case Follow
        case Message
        
        var description: String {
            switch self {
            case .Like: return " liked your post"
            case .Comment: return " commented on your post"
            case .Follow: return " started following you"
            case .Message: return " sent you a message"
            }
        }
        
        init(index: Int) {
            switch index {
            case 0: self = .Like
            case 1: self = .Comment
            case 2: self = .Follow
            case 3: self = .Message
            default: self = .Like
            }
        }
    }
    
    var creationDate: Date!
    var uid: String!
    var postId: String?
    var post: Post?
    var user: User!
    var type: Int?
    var notificationType: NotificationType!
    var didCheck = false
    
    init(user: User, post: Post? = nil, dictionary: Dictionary<String, AnyObject>) {
        
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
            self.didCheck = false
        } else {
            self.didCheck = true
        }
    }
    
    
}
