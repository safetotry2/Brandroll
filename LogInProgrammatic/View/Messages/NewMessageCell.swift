//
//  NewMessageCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/9/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Kingfisher
import UIKit

class NewMessageCell: UITableViewCell {

    // MARK: - Properties
    
    var user: User? {
        
        didSet {
            guard let profileImageUrl = user?.profileImageUrl,
                  let url = URL(string: profileImageUrl) else { return }
            
            let fullname = user?.name ?? ""
            let occupation = user?.occupation ?? ""
            
            let resource = ImageResource(downloadURL: url)
            profileImageView.kf.setImage(with: resource)
            textLabel?.text = fullname
            detailTextLabel?.text = occupation
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        textLabel?.text = "Name"
        detailTextLabel?.text = "Occupation"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y + 2, width: self.frame.width - 108, height: (detailTextLabel?.frame.height)!)
        
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
