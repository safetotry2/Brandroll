//
//  ChatController.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/11/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "ChatCell"

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var user: User?
    var message: Message?
    var messages = [Message]()
    
    private var chatsRefHandle: DatabaseHandle?
        
    lazy var containerView: ChatInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        let containerView = ChatInputAccessoryView(frame: frame)
        containerView.backgroundColor = .white
        containerView.delegate = self
        return containerView
    }()
    
    // MARK: - Functions
    // MARK: Override
    
    deinit {
        print("ChatController deallocated! 🧤")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        collectionView.backgroundColor = .white
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.keyboardDismissMode = .interactive
        
        configureKeyboardObservers()
        observeMessages()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        
        removeObserver()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func removeObserver() {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let chatPartnerId = self.user?.uid,
              let chatsRefHandle = self.chatsRefHandle else { return }
        
        USER_MESSAGES_REF
            .child(currentUid)
            .child(chatPartnerId)
            .removeObserver(withHandle: chatsRefHandle)
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var height: CGFloat = 80

        let message = messages[indexPath.item]

        height = estimateFrameForText(message.messageText).height + 20

        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        cell.message = messages[indexPath.row]
        configureMessge(cell: cell, message: messages[indexPath.item])
        return cell
    }
    
    // MARK: - Handlers
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleFullnameTapped() {
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        userProfileVC.fromTabBar = false
        navigationController?.pushViewController(userProfileVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    @objc func handleKeyboardDidShow() {
        scrollToBottom()
    }
    
    func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func configureKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func configureMessge(cell: ChatCell, message: Message) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.messageText).width + 32
        cell.frame.size.height = estimateFrameForText(message.messageText).height + 16
        
        if message.fromId == currentUid {
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
            cell.textView.textColor = .white
        } else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = .black
        }
    }
    
    func configureNavigationBar() {
        guard let user = self.user else { return }
        
        let fullnameButton = UIButton(type: .custom)
        fullnameButton.setTitle(user.name, for: .normal)
        fullnameButton.setTitleColor(.black, for: .normal)
        fullnameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        fullnameButton.addTarget(self, action: #selector(handleFullnameTapped), for: .touchUpInside)
        
        navigationItem.titleView = fullnameButton
    }

    func uploadMessageNotification() {
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        guard let toId = user.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
            
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": fromId,
                      "type": MESSAGE_INT_VALUE] as [String : Any]
            
        let notificationRef = NOTIFICATIONS_REF.child(toId).childByAutoId()
        notificationRef.updateChildValues(values)
    }
    
    // MARK: - API
    
    func observeMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let chatPartnerId = self.user?.uid else { return }
        
        chatsRefHandle = USER_MESSAGES_REF
            .child(currentUid)
            .child(chatPartnerId)
            .observe(.childAdded) { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessage(withMessageId: messageId)
            }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let message = Message(key: messageId, dictionary: dictionary)
            message.setSeen()
            self.messages.append(message)

            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
}


extension ChatController: ChatInputAccessoryViewDelegate {
    func didSubmit(forChat chat: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)

        guard let uid = user.uid else { return }

        let messageValues = [
            "creationDate": creationDate,
            "fromId": currentUid,
            "toId": uid,
            "messageText": chat,
            "seen": false
        ] as [String: Any]

        let messageRef = MESSAGES_REF.childByAutoId()

        guard let messageKey = messageRef.key else { return }

        messageRef.updateChildValues(messageValues) { (err, ref) in
            USER_MESSAGES_REF.child(user.uid).child(currentUid).updateChildValues([messageKey: 1])
            USER_MESSAGES_REF.child(currentUid).child(user.uid).updateChildValues([messageKey: 1])
        }
        
        uploadMessageNotification()
        self.containerView.clearChatTextView()
    }
}

