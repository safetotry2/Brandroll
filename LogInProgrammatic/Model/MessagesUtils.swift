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
    
    var lastFetchedMessage: Message?
    
    /// The handle of the Firebase observer from `fetchMessages`. The uid is the one that is passed into `messagesRefHandle`.
    typealias firstTuple = (dbHandle: DatabaseHandle?, uidUser: String?)
    private var messagesRefHandles = [firstTuple]()
    
    /// The second handle. The uid is passed into `userMessagesRefHandle`.
    typealias secondTuple = (dbHandle: DatabaseHandle?, uidUser: String?, uidMessage: String?)
    private var userMessagesRefHandles = [secondTuple]()
    
    // MARK: Functions
    
    func removeObserver() {
        // The first observers.
        messagesRefHandles.forEach { (dbHandle, uidUser) in
            if let handle = dbHandle,
               let uidUser = uidUser {
                USER_MESSAGES_REF
                    .child(uidUser)
                    .removeObserver(withHandle: handle)
            }
        }
        
        // The second observer
        userMessagesRefHandles.forEach { (dbHandle, uidUser, uidMessage) in
            if let handle = dbHandle,
               let uidUser = uidUser,
               let uidMessage = uidMessage {
                USER_MESSAGES_REF
                    .child(uidUser)
                    .child(uidMessage)
                    .removeObserver(withHandle: handle)
            }
        }
    }
    
    func fetchMessages(userId: String, completion block: FetchMessageCompletion?) {
        var newMessagesRefHandle: firstTuple = (nil, nil)
        
        newMessagesRefHandle.uidUser = userId
        
        let newHandle = USER_MESSAGES_REF
            .child(userId)
            .observe(.childAdded, with: { [weak self] (snapshot) in
                let messageId = snapshot.key
                
                self?.continueFetchingMessage(
                    userId: userId,
                    messageId: messageId,
                    completion: block
                )
            }, withCancel: { (error) in
                if let block = block { block?("") }
            })
        
        newMessagesRefHandle.dbHandle = newHandle
        
        // store to handles array.
        messagesRefHandles.append(newMessagesRefHandle)
    }
    
    func continueFetchingMessage(userId: String, messageId: String, completion block: FetchMessageCompletion?) {
        var newUserMessagesRefHandle: secondTuple = (nil, nil, nil)
        
        newUserMessagesRefHandle.uidUser = userId
        newUserMessagesRefHandle.uidMessage = messageId
        
        let newHandle = USER_MESSAGES_REF
            .child(userId)
            .child(messageId)
            .observe(.childAdded) { [weak self] (snapshot) in
                let messageId = snapshot.key
                self?.fetchMessage(withMessageId: messageId, complection: block)
            }
        
        newUserMessagesRefHandle.dbHandle = newHandle
        
        // store to handles array.
        userMessagesRefHandles.append(newUserMessagesRefHandle)
    }
    
    func fetchMessage(withMessageId messageId: String, complection block: FetchMessageCompletion?) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {
                if let block = block { block?("") }
                return
            }

            let message = Message(key: messageId, dictionary: dictionary)

            Database.fetchUser(with: message.getChatPartnerId()) { [weak self] (user) in
                message.user = user

                let chatPartnerId = message.getChatPartnerId()

                let array = Array(MessagesController.messagesDictionary.values)
                MessagesController.messagesDictionary[chatPartnerId] = message
                MessagesController.messages = array

                // sort messages based on creation date of last message
                MessagesController.messages.sort { (message1, message2) -> Bool in
                    return message1.creationDate > message2.creationDate
                }

                self?.lastFetchedMessage = MessagesController.messages.last

                // completion
                if let block = block { block?(chatPartnerId) }
            }

        }, withCancel: { error in
            if let block = block { block?("") }
        })
    }
}
