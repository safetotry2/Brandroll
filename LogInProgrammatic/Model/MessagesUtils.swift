//
//  MessagesUtils.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 2/2/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import Foundation

class MessagesUtils: NSObject {
    
    // MARK: - Properties
    
    typealias FetchMessageCompletion = ((_ chatPartnerId: String) -> Void)?
    
    private var lastFetchedMessage: Message?
    
    /// The handle of the Firebase observer from `fetchMessages`.
    private var messagesRefHandle: DatabaseHandle?
    /// The uid passed into `messagesRefHandle`.
    private var uiForMessages: String?
    
    /// Second handle.
    private var userMessagesRefHandle: DatabaseHandle?
    /// The uid passed into `userMessagesRefHandle`.
    private var uidForUserMessagesRefHandle: String?
    
    // MARK: Functions
    
    func removeObserver() {
        if let handle = userMessagesRefHandle,
           let uiForMessages = uiForMessages,
           let uidForUserMessagesRefHandle = uidForUserMessagesRefHandle {
            USER_MESSAGES_REF
                .child(uiForMessages)
                .child(uidForUserMessagesRefHandle)
                .removeObserver(withHandle: handle)
            
            USER_MESSAGES_REF
                .child(uiForMessages)
                .child(uidForUserMessagesRefHandle)
                .removeAllObservers()
        }
        
        if let handle = messagesRefHandle,
           let uiForMessages = uiForMessages {
            
            USER_MESSAGES_REF
                .child(uiForMessages)
                .removeObserver(withHandle: handle)
            
            USER_MESSAGES_REF
                .child(uiForMessages)
                .removeAllObservers()
        }
    }
    
    func fetchMessages(userId: String, completion block: FetchMessageCompletion) {
        uiForMessages = userId
        
        messagesRefHandle = USER_MESSAGES_REF
            .child(userId)
            .observe(.childAdded, with: { (snapshot) in
                let uid = snapshot.key
                                
//                self.userMessagesRefHandle = USER_MESSAGES_REF
//                    .child(userId)
//                    .child(uid)
//                    .observe(.childAdded) { (snapshot) in
//                        let messageId = snapshot.key
//                        self.fetchMessage(withMessageId: messageId, complection: block)
//                    }
            }, withCancel: { (error) in
                block?("")
            })
    }
    
    func fetchMessage(withMessageId messageId: String, complection block: FetchMessageCompletion) {
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
                
                self.lastFetchedMessage = MessagesController.messages.last
                
                // completion
                block?(chatPartnerId)
            }
            
        }, withCancel: { error in
            block?("")
        })
    }
}
