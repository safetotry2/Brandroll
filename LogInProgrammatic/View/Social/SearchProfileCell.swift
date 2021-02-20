//
//  SearchProfileCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 1/24/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import Kingfisher
import UIKit

class SearchProfileCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: SearchProfileCellDelegate?
    
    var user: User? {
        didSet {
            if let profileImageUrl = user?.profileImageUrl,
               let url = URL(string: profileImageUrl) {
                let resource = ImageResource(downloadURL: url)
                profileImageView.kf.setImage(with: resource)
            }
            
            if let fullname = user?.name {
                fullnameLabel.text = fullname
            } else if user?.name == nil {
                fullnameLabel.text = "Problem User"
            }
            
            if let occupation = user?.occupation {
                occupationLabel.text = occupation
            } else if user?.occupation == nil {
                occupationLabel.text = " "
            }
            
            configureFollowButton()
        }
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        return label
    }()
    
    let occupationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .darkGray
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
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    func layoutView() {
        
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4.0
        
        containerView.layer.cornerRadius = 8.0
        containerView.layer.masksToBounds = true
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, width: 0, height: 0)
        
        containerView.addSubview(profileImageView)
        profileImageView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 70, height: 70)
        profileImageView.layer.cornerRadius = 70/2
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        containerView.addSubview(fullnameLabel)
        fullnameLabel.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 6, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        fullnameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        containerView.addSubview(occupationLabel)
        occupationLabel.anchor(top: fullnameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        occupationLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        containerView.addSubview(followButton)
        followButton.anchor(top: occupationLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 20)
        followButton.layer.cornerRadius = 8.0

    }
    
    func configureFollowButton() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = user else { return }
        
        if currentUid == user.uid {
            self.followButton.isHidden = true
        } else {
            user.checkIfUserIsFollowed { (followed) in
                if followed {
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                    self.followButton.layer.borderWidth = 0.4
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.backgroundColor = .white
                } else {
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                }
            }
        }
    }
    
}
