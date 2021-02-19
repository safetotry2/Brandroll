//
//  Message.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/10/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    /// Fetched separately.
    var user: User?

    var messageText: String!
    var fromId: String!
    var toId: String!
    var creationDate: Date!
    var seen: Int = 0
    var key: String!
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        
        if let messageText = dictionary["messageText"] as? String {
            self.messageText = messageText
        }
        
        if let fromId = dictionary["fromId"] as? String {
            self.fromId = fromId
        }
        
        if let toId = dictionary["toId"] as? String {
            self.toId = toId
        }
        
        if let seen = dictionary["seen"] as? Int {
            self.seen = seen
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func getChatPartnerId() -> String {
        guard let currentUid = Auth.auth().currentUser?.uid else { return ""}
        
        if fromId == currentUid {
            return toId
        } else {
            return fromId
        }
    }
    
    func setSeen() {
        // Only proceed if we are setting seen to the message of the partner.
        // and not our own message.
        guard let currentUid = Auth.auth().currentUser?.uid,
              currentUid != fromId else { return }
        seen = 1
        MESSAGES_REF
            .child(key)
            .child("seen")
            .setValue(1)
    }
}

// MARK: - Equatable

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.key == rhs.key
    }
}
