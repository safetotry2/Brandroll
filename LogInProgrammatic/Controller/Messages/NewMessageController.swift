//
//  NewMessageController.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/9/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NewMessageCell"

class NewMessageController: UITableViewController {
    
    // MARK: - Properties
    
    var users = [User]()
    var messagesController: MessagesController?
    
    private var usersRefHandle: DatabaseHandle?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure navigation bar
        configureNavigationBar()
        
        // register cell
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        fetchUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObserver()
    }
    
    func removeObserver() {
        guard let usersRefHandle = usersRefHandle else { return }
        
        USER_FOLLOWER_REF
            .removeObserver(withHandle: usersRefHandle)
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessageCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatController(forUser: user)
        }
    }
    
    // MARK: - Handlers
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func configureNavigationBar() {
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    // MARK: - API
    
    func fetchUsers() {
        usersRefHandle = USER_REF
            .observe(.childAdded) { (snapshot) in
                let uid = snapshot.key
                
                if uid != Auth.auth().currentUser?.uid {
                    Database.fetchUser(with: uid) { (user) in
                        guard let user = user else { return }
                        self.users.append(user)
                        self.tableView.reloadData()
                    }
                }
            }
    }
}
