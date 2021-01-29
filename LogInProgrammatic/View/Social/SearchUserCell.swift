//
//  SearchUserCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/28/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    // MARK: - Properties
    
    var user: User? {
    
        didSet {
            //guard let profileImageUrl = user?.profileImageUrl else { return }
            //guard let fullName = user?.name else { return }
            //guard let occupation = user?.occupation else { return }
            
            if let profileImageUrl = user?.profileImageUrl {
                profileImageView.loadImage(with: profileImageUrl)
            }
            
            if let fullName = user?.name {
                nameLabel.text = fullName
            }
            
            if let occupation = user?.occupation {
                occupationLabel.text = occupation
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
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    let occupationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 6, paddingBottom: 0, paddingRight: 0, width: nameLabel.frame.width, height: nameLabel.frame.height)
        
        addSubview(occupationLabel)
        occupationLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 6, paddingBottom: 0, paddingRight: 0, width: occupationLabel.frame.width, height: occupationLabel.frame.height)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
