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
    private var uidUser: String?
    
    /// Second handle.
    private var userMessagesRefHandle: DatabaseHandle?
    /// The uid passed into `userMessagesRefHandle`.
    private var uidMessage: String?
    
    // MARK: Functions
    
    func removeObserver() {
        // The first observer.
        if let handle = messagesRefHandle,
           let uidUser = uidUser {
            
            USER_MESSAGES_REF
                .child(uidUser)
                .removeObserver(withHandle: handle)
            
            USER_MESSAGES_REF
                .child(uidUser)
                .removeAllObservers()
        }
        
        // The second observer
        if let handle = userMessagesRefHandle,
           let uiForMessages = uidUser,
           let uidForUserMessagesRefHandle = uidMessage {
            USER_MESSAGES_REF
                .child(uiForMessages)
                .child(uidForUserMessagesRefHandle)
                .removeObserver(withHandle: handle)
            
            USER_MESSAGES_REF
                .child(uiForMessages)
                .child(uidForUserMessagesRefHandle)
                .removeAllObservers()
        }
    }
    
    func fetchMessages(userId: String, completion block: FetchMessageCompletion?) {
        uidUser = userId
        
        messagesRefHandle = USER_MESSAGES_REF
            .child(userId)
            .observe(.childAdded, with: { [weak self] (snapshot) in
                let uid = snapshot.key
                self?.uidMessage = uid
                self?.continueFetchingMessage(
                    userId: userId,
                    messageId: uid,
                    completion: nil
                )
            }, withCancel: { (error) in
                if let block = block { block?("") }
            })
    }
    
    func continueFetchingMessage(userId: String, messageId: String, completion block: FetchMessageCompletion?) {
        userMessagesRefHandle = USER_MESSAGES_REF
            .child(userId)
            .child(messageId)
            .observe(.childAdded) { [weak self] (snapshot) in
                let messageId = snapshot.key
                self?.fetchMessage(withMessageId: messageId, complection: block)
            }
    }
    
    func fetchMessage(withMessageId messageId: String, complection block: FetchMessageCompletion?) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {
                if let block = block { block?("") }
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
                if let block = block { block?(chatPartnerId) }
            }

        }, withCancel: { error in
            if let block = block { block?("") }
        })
    }
}
