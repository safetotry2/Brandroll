//
//  SearchPostCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/8/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Kingfisher
import UIKit

class SearchPostCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            if let imageUrl = post?.imageUrl,
               let url = URL(string: imageUrl) {
                let resource = ImageResource(downloadURL: url)
                postImageView.kf.setImage(with: resource)   
            }
        }
    }
    
    let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
