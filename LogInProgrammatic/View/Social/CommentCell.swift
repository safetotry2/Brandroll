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
            //guard let user = comment?.user else { return }
            //guard let profileImageUrl = user.profileImageUrl else { return }
            
            if let owner = comment?.user {
                if let imageUrl = owner.profileImageUrl,
                   let url = URL(string: imageUrl) {
                    let resource = ImageResource(downloadURL: url)
                    self.profileImageView.kf.setImage(with: resource)
                }
                
                self.fullnameButton.setTitle(owner.name ?? "", for: .normal)
                self.commentText.text = comment?.commentText ?? ""
                self.timestamp.text = comment?.creationDate.timeStampForComment() ?? ""
            }
            
//            let name = user.name ?? ""
//            let commentText = comment?.commentText ?? ""
//            let timestamp = comment?.creationDate.timeStampForComment() ?? ""
//
//            let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
//            attributedText.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
//            attributedText.append(NSAttributedString(string: " \(timestamp)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
//
//
//            commentTextView.attributedText = attributedText
        }
    }
    
    // test
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
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
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleFullnameTapped), for: .touchUpInside)
        return button
    }()
    
    let commentText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        //label.numberOfLines = 2
        return label
    }()
    
    let timestamp: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
//    let commentTextView: UITextView = {
//        let tv = UITextView()
//        tv.font = UIFont.systemFont(ofSize: 12)
//        tv.isScrollEnabled = false
//        tv.translatesAutoresizingMaskIntoConstraints = false
//        return tv
//    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // test
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.white
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Handlers
    
    //test
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    // test
    fileprivate func setupViews() {
                
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        //profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        addSubview(fullnameButton)
        fullnameButton.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(commentText)
        commentText.anchor(top: topAnchor, left: fullnameButton.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(timestamp)
        timestamp.anchor(top: topAnchor, left: commentText.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
//        contentView.addSubview(commentTextView)
//        commentTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
//        commentTextView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
//        commentTextView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
//        commentTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
    }
    
    @objc func handleFullnameTapped() {
        delegate?.handleFullnameTapped(for: self)
    }
    
}
