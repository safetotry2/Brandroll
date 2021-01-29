//
//  MessagesController.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/9/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "MessagesCell"

class MessagesController: UITableViewController {
    
    // MARK: - Properties
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var userUid: String?
    var currentKey: String?
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure navigation bar
        configureNavigationBar()
        
        // register cell
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // fetch messages
        fetchMessages()
        
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.delegate = self
        cell.message = messages[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if messages.count > 4 {
            if indexPath.item == messages.count - 1 {
                fetchMessages()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chatPartnerId = message.getChatPartnerId()
        Database.fetchUser(with: chatPartnerId) { (user) in
            self.showChatController(forUser: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            guard let userUid = userUid else { return }
            
            USER_MESSAGES_REF.child(currentUid).child(userUid).removeValue { (err, ref) in
                self.messages.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Handlers
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func showChatController(forUser user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Messages"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
    }
    
    // MARK: - API
    
    func fetchMessages() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.messages.removeAll()
        self.messagesDictionary.removeAll()
        self.tableView.reloadData()

        USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { (snapshot) in

            let uid = snapshot.key

            USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded) { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessage(withMessageId: messageId)
            }
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }

            let message = Message(dictionary: dictionary)
            let chatParnerId = message.getChatPartnerId()
            self.userUid = chatParnerId
            self.messagesDictionary[chatParnerId] = message
            self.messages = Array(self.messagesDictionary.values)
            
            // sort messages based on creation date of last message
            self.messages.sort { (message1, message2) -> Bool in
                return message1.creationDate > message2.creationDate
            }

            self.tableView.reloadData()
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
}

extension MessagesController: MessageCellDelegate {
    
    func configureUserData(for cell: MessageCell) {
        guard let chatPartnerId = cell.message?.getChatPartnerId() else { return }
        
        Database.fetchUser(with: chatPartnerId) { (user) in
            cell.profileImageView.loadImage(with: user.profileImageUrl)
            cell.nameLabel.text = user.name
        }
    }
}
