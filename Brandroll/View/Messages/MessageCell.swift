//
//  MessagesCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/9/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import FirebaseAuth
import Kingfisher
import UIKit

class MessageCell: UITableViewCell {

    // MARK: - Properties
        
    var message: Message? {
        didSet {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            
            let messageText = message?.messageText ?? ""
            messageTextLabel.text = messageText
            
            if let messageTime = message?.creationDate {
                timeStampLabel.text = messageTime.timeOrDateToDisplay(from: messageTime)
            }
            
            var dotIsHidden = message?.seen == 1
            
            if message?.fromId == currentUid {
                dotIsHidden = true
            }
            
            dot.isHidden = dotIsHidden
            
            if let profileImageUrl = message?.user?.profileImageUrl,
               let url = URL(string: profileImageUrl) {
                let resource = ImageResource(downloadURL: url)
                profileImageView.kf.setImage(with: resource)
            } else if message?.user?.profileImageUrl == nil {
                profileImageView.image = #imageLiteral(resourceName: "circle")
            }
            
            nameLabel.text = message?.user?.name ?? ""
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "circle")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let timeStampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.text = "2h"
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    let messageTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var dot: UIView = {
        let dot = UIView()
        dot.isHidden = true
        dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
        dot.layer.cornerRadius = 3
        dot.translatesAutoresizingMaskIntoConstraints = false
        return dot
    }()

    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(timeStampLabel)
        timeStampLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 6, paddingBottom: 0, paddingRight: 12, width: nameLabel.frame.width, height: nameLabel.frame.height)

        addSubview(messageTextLabel)
        messageTextLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 1, paddingLeft: 6, paddingBottom: 0, paddingRight: 12, width: self.frame.width - 96, height: messageTextLabel.frame.height)
        
        addSubview(dot)
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 6),
            dot.heightAnchor.constraint(equalToConstant: 6),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
