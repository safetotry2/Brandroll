//
//  CommentCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/2/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import Kingfisher
import UIKit

class CommentCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: CommentCellDelegate?
    
    var comment: Comment? {
        didSet {
            
            if let owner = comment?.user {
                if let imageUrl = owner.profileImageUrl,
                   let url = URL(string: imageUrl) {
                    let resource = ImageResource(downloadURL: url)
                    self.profileImageView.kf.setImage(with: resource)
                }
                
                self.fullnameButton.setTitle(owner.name ?? "", for: .normal)
                self.commentTextView.text = comment?.commentText ?? ""
                self.timestamp.text = comment?.creationDate.timeStampForComment() ?? ""
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var fullnameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Fullname", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleFullnameTapped), for: .touchUpInside)
        return button
    }()
    
    let commentText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    let timestamp: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.isScrollEnabled = false
        let padding = tv.textContainer.lineFragmentPadding
        tv.textContainerInset = UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        return tv
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2

        addSubview(fullnameButton)
        fullnameButton.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: -2, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(commentTextView)
        commentTextView.anchor(top: fullnameButton.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        commentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true

        addSubview(timestamp)
        timestamp.anchor(top: commentTextView.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Handlers
    
    @objc func handleFullnameTapped() {
        delegate?.handleFullnameTapped(for: self)
    }
    
}
