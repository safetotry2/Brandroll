//
//  UIButton+Setup.swift
//  Brandroll
//
//  Created by Glenn Posadas on 9/23/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import UIKit

/// Category for adding helpfer methods for setting up buttons
extension UIButton {
    
    /// Setups the button with attributed text.
    func setup(
        _ title: String,
        normalFont: UIFont = UIFont.systemFont(ofSize: 14.0),
        normalTextColor: UIColor,
        highlightedFont: UIFont? = nil,
        highlightedTextColor: UIColor? = nil,
        backgroundColor: UIColor = .clear,
        horizontalAlignment: UIControl.ContentHorizontalAlignment = .center,
        isUnderlined: Bool = false,
        setGradientBG: Bool = false) {
        
        let normalAttrib = NSAttributedString(
            string: title,
            attributes: [
                .font : normalFont,
                .foregroundColor : normalTextColor,
                .underlineStyle : isUnderlined ? NSUnderlineStyle.single.rawValue : 0
            ]
        )

        let highlightedAttrib = NSAttributedString(
            string: title,
            attributes: [
                .font : highlightedFont ?? normalFont,
                .foregroundColor : highlightedTextColor ?? UIColor.lightGray,
                .underlineStyle : isUnderlined ? NSUnderlineStyle.single.rawValue : 0
            ]
        )
        
        self.setAttributedTitle(normalAttrib, for: .normal)
        self.setAttributedTitle(highlightedAttrib, for: .highlighted)
        self.contentHorizontalAlignment = horizontalAlignment
        self.contentVerticalAlignment = .center
        self.backgroundColor = backgroundColor
        
    }
    
    /// Setups the button with an image, usually at the leading side.
    func setupWithIcon(
        _ icon: UIImage,
        imageEdgeInsets: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: -3, bottom: 0, right: 0),
        titleEdgeInsets: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: -8)
        ) {
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.setImage(icon, for: .normal)
    }
    
    func setupWithAttributedTitle(
        mutableString: NSMutableAttributedString,
        attributedStrings: [NSAttributedString]
    ) {
        for attributedString in attributedStrings {
            mutableString.append(attributedString)
        }
        
        self.setAttributedTitle(mutableString, for: .normal)
    }
    
}

