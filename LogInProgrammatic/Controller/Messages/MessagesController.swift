//
//  MessagesController.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/9/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import Kingfisher
import SVProgressHUD
import UIKit

private let reuseIdentifier = "MessagesCell"

class MessagesController: UITableViewController {
    
    // MARK: - Properties
    
    static var messages = [Message]()
    static var messagesDictionary = [String: Message]()
    
    private var messagesUtils: MessagesUtils?
    private var didPresentNewMessage = false
    
    var userUid: String?
    var currentKey: String?
    
    // MARK: - Functions
    // MARK: Overrides
    
    deinit {
        print("MessagesVC deallocated! 🦷")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure navigation bar
        configureNavigationBar()
        
        // register cell
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        messagesUtils = MessagesUtils()
        MessagesController.messages.removeAll()
        MessagesController.messagesDictionary.removeAll()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if didPresentNewMessage {
            didPresentNewMessage = false
        } else {
            // fetch messages
            fetchMessages()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        messagesUtils?.removeObserver()
        messagesUtils = nil
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = MessagesController.messages.count
        print("MessagesVC numberOfRowsInSection: \(count)")
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.message = MessagesController.messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if MessagesController.messages.count > 4 {
            let lastStoredMessage = MessagesController.messages.last
            let previousFetchedMessage = messagesUtils?.lastFetchedMessage
            
            if indexPath.item == MessagesController.messages.count - 1 && lastStoredMessage != previousFetchedMessage {
                fetchMessages()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = MessagesController.messages[indexPath.row]
        let chatPartnerId = message.getChatPartnerId()
        
        message.setSeen()
        
        SVProgressHUD.show()
        Database.fetchUser(with: chatPartnerId) { (user) in
            SVProgressHUD.dismiss {
                guard let user = user else { return }
                self.showChatController(forUser: user)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
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
                MessagesController.messages.remove(at: indexPath.row)
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
        didPresentNewMessage = true
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
        
        SVProgressHUD.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            // Just in case for 5 seconds nothing happens,
            // remove the HUD. This happens because Firebase won't return a callback if we have an empty data.
            SVProgressHUD.dismiss()
        }
        
        messagesUtils?.fetchMessages(userId: currentUid) { (partnerId) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                SVProgressHUD.dismiss()
            }
            
            self.userUid = partnerId
            
            print("MessagesVC fetchMessage messages count: \(MessagesController.messages.count)")
            
            self.tableView.reloadData()
        }
    }
}
