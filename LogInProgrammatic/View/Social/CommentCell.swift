//
//  CommentCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/2/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let user = comment?.user else { return }
            
            let name = user.name ?? ""
            let commentText = comment?.commentText ?? ""
            let timestamp = comment?.creationDate.timeStampForComment() ?? ""
            
            let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
            attributedText.append(NSAttributedString(string: " \(timestamp)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            commentTextView.attributedText = attributedText
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
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
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
    
    //test
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    // test
    fileprivate func setupViews() {
        contentView.addSubview(commentTextView)
        commentTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        commentTextView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        commentTextView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        commentTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
    }
    
}
