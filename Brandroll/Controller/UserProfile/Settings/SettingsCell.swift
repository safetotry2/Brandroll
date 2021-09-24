//
//  SettingsCell.swift
//  Brandroll
//
//  Created by Glenn Posadas on 9/19/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import SnapKit
import UIKit

class SettingsCell: UITableViewCell {
    
    // MARK: - Properties
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
    
    lazy var separator: UIView = {
        let separator = UIView()
        //separator.backgroundColor = .lightGray
        separator.backgroundColor = .none
        separator.alpha = 0.8
        return separator
    }()
    
    lazy var chevron: UIImageView = {
        let image = UIImage(named: "chevron")
        let chevron = UIImageView(image: image)
        chevron.contentMode = .scaleAspectFit
        return chevron
    }()
    
    var separatorBottom: Constraint?
    var sectionType: String! {
        didSet {
            let separatorToBottomInset: CGFloat = sectionType == "Push Notifications" ? 16 : 0
            separatorBottom?.update(inset: separatorToBottomInset)
            chevron.isHidden = sectionType != "Push Notifications"
        }
    }
    
    // MARK: - Functions
    
    func setHighlightedAnimation() {
        UIView.animate(withDuration: 0.3) {
            let value: CGFloat = self.isHighlighted ? 0.5 : 1
            self.alpha = value
        }
    }
    
    // MARK: Overrides
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        setHighlightedAnimation()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .none
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 15000, bottom: 0, right: 0)
        
        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(chevron)
        chevron.snp.makeConstraints {
            $0.width.height.equalTo(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(label)
        }
        
        contentView.addSubview(separator)
        separator.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(label.snp.bottom)
            separatorBottom = $0.bottom.equalToSuperview().constraint
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

