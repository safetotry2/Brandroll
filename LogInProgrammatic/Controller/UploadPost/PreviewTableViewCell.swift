//
//  PreviewTableViewCell.swift
//  TabandNav
//
//  Created by Mac on 7/30/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit

class PreviewTableViewCell: UITableViewCell {
    
    var heightConstraint: NSLayoutConstraint?
    
    var cellImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(cellImageView)
        cellImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        self.heightConstraint = cellImageView.heightAnchor.constraint(equalToConstant: 0)
        self.heightConstraint?.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
