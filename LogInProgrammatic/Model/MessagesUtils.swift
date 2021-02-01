//
//  MessagesUtils.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 2/2/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Foundation

struct MessagesUtils {
    typealias FetchMessageCompletion = ((_ chatPartnerId: String) -> Void)?
    
    static func fetchMessages(userId: String, completion block: FetchMessageCompletion) {
        USER_MESSAGES_REF
            .child(userId)
            .observe(.childAdded) { (snapshot) in
                let uid = snapshot.key
                
                USER_MESSAGES_REF
                    .child(userId)
                    .child(uid)
                    .observe(.childAdded) { (snapshot) in
                        let messageId = snapshot.key
                        MessagesUtils.fetchMessage(withMessageId: messageId, complection: block)
                    }
            }
    }
    
    static func fetchMessage(withMessageId messageId: String, complection block: FetchMessageCompletion) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let message = Message(dictionary: dictionary)
            let chatPartnerId = message.getChatPartnerId()
            
            MessagesController.messagesDictionary[chatPartnerId] = message
            MessagesController.messages = Array(MessagesController.messagesDictionary.values)
            
            // sort messages based on creation date of last message
            MessagesController.messages.sort { (message1, message2) -> Bool in
                return message1.creationDate > message2.creationDate
            }
            
            // completion
            block?(chatPartnerId)
        }
    }
}
