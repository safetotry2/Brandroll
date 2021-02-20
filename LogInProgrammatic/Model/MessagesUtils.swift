//
//  MessagesUtils.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 2/2/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import Foundation

struct MessagesUtils {
    
    // MARK: - Properties
    
    typealias FetchMessageCompletion = ((_ chatPartnerId: String) -> Void)?
    
    static var lastFetchedMessage: Message?
    
    /// The handle of the Firebase observer from `fetchMessages`.
    static var messagesRefHandle: DatabaseHandle?
    /// Second handle.
    static var userMessagesRefHandle: DatabaseHandle?
    /// The uid passed into `userMessagesRefHandle`.
    static var uidUserMessagesRef: String = ""
    
    // MARK: Functions
    
    static func removeObserver() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if let handle = messagesRefHandle {
            USER_MESSAGES_REF
                .child(currentUid)
                .removeObserver(withHandle: handle)
        }
        
        if let handle = userMessagesRefHandle {
            USER_MESSAGES_REF
                .child(currentUid)
                .child(uidUserMessagesRef)
                .removeObserver(withHandle: handle)
        }
        
        USER_MESSAGES_REF.removeAllObservers()
    }
    
    static func fetchMessages(userId: String, completion block: FetchMessageCompletion) {
        messagesRefHandle = USER_MESSAGES_REF
            .child(userId)
            .observe(.childAdded, with: { (snapshot) in
                let uid = snapshot.key
                self.uidUserMessagesRef = uid
                
                userMessagesRefHandle = USER_MESSAGES_REF
                    .child(userId)
                    .child(uid)
                    .observe(.childAdded) { (snapshot) in
                        let messageId = snapshot.key
                        MessagesUtils.fetchMessage(withMessageId: messageId, complection: block)
                    }
            }, withCancel: { (error) in
                block?("")
            })
    }
    
    static func fetchMessage(withMessageId messageId: String, complection block: FetchMessageCompletion) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {
                block?("")
                return
            }
            
            let message = Message(key: messageId, dictionary: dictionary)
            
            Database.fetchUser(with: message.getChatPartnerId()) { (user) in
                message.user = user
                
                let chatPartnerId = message.getChatPartnerId()
                
                MessagesController.messagesDictionary[chatPartnerId] = message
                MessagesController.messages = Array(MessagesController.messagesDictionary.values)
                
                // sort messages based on creation date of last message
                MessagesController.messages.sort { (message1, message2) -> Bool in
                    return message1.creationDate > message2.creationDate
                }
                
                MessagesUtils.lastFetchedMessage = MessagesController.messages.last
                
                // completion
                block?(chatPartnerId)
            }
            
        }, withCancel: { error in
            block?("")
        })
    }
}
