//
//  NotificationCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/4/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    // MARK: - Properties
    
    var delegate: NotitificationCellDelegate?
    
    var notification: Notification? {
        
        didSet {
            
            guard let user = notification?.user else { return }
            guard let profileImageUrl = user.profileImageUrl else { return }
            
            // configure notification label
            configureNotificationLabel()
            
            // configure notification type
            configureNotificationType()
            
            profileImageView.loadImage(with: profileImageUrl)
                        
            if let post = notification?.post {
                postImageView.loadImage(with: post.imageUrl)
            }
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let notificationLable: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        postTap.numberOfTapsRequired = 1
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(postTap)
        return iv
    }()
    
    // MARK: - Handlers
    
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    @objc func handlePostTapped() {
        delegate?.handlePostTapped(for: self)
    }
    
    func configureNotificationLabel() {
        
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        guard let username = user.username else { return }
        let notificationMessage = notification.notificationType.description
        guard let notificationDate = getNotificationTimestamp() else { return }

        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " \(notificationDate)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        notificationLable.attributedText = attributedText
    }
    
    func configureNotificationType() {
        
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
                
        if notification.notificationType != .Follow {
            
            // notification type is comment or like
            addSubview(postImageView)
            postImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
            postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            followButton.isHidden = true
            postImageView.isHidden = false
            
        } else {
            
            // notification type is follow
            addSubview(followButton)
            followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
            followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            followButton.layer.cornerRadius = 3
            followButton.isHidden = false
            postImageView.isHidden = true
            
            user.checkIfUserIsFollowed { (followed) in
                
                if followed {
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.backgroundColor = .white
                } else {
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                    
                }
                
            }
        }
        
        addSubview(notificationLable)
        notificationLable.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        notificationLable.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func getNotificationTimestamp() -> String? {
        
        guard let notification = self.notification else { return nil }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        let now = Date()
        return dateFormatter.string(from: notification.creationDate, to: now)
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
