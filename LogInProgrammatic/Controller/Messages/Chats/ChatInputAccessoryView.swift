//
//  ChatInputAccessoryView.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/28/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit

class ChatInputAccessoryView: UIView {

    // MARK: - Properties
    
    var delegate: ChatInputAccessoryViewDelegate?
    
    let chatTextView: ChatInputTextView = {
        let tv = ChatInputTextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        return tv
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUploadChat), for: .touchUpInside)
        return button
    }()

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 50)
        
        addSubview(chatTextView)
        chatTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        addSubview(separatorView)
        separatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // MARK: - Handlers

    @objc func handleUploadChat() {
        guard let chat = chatTextView.text else { return }
        delegate?.didSubmit(forChat: chat)
    }
    
    func clearChatTextView() {
        chatTextView.placeholderLabel.isHidden = false
        chatTextView.text = nil
    }
    
}
