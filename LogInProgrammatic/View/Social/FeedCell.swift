//
//  FeedCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 10/26/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import Kingfisher
import UIKit

class FeedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: FeedCellDelegate?
    
    private var maskedView: UIView!
    
    var post: Post? {
        didSet {
            if let imageUrl = post?.imageUrl,
               let url = URL(string: imageUrl) {
                let resource = ImageResource(downloadURL: url)
                self.postImageView.kf.setImage(with: resource)
            }
            
            configureLikeLabel()
            configureLikeButton()
            configureCaption()
        }
    }
        
    lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 20
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return iv
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var likeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.text = "3 likes"
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // add gesture recognizer to label
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        likeTap.numberOfTouchesRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postImageView)
        postImageView.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: nil,
            right: rightAnchor,
            paddingTop: 14,
            paddingLeft: 12,
            paddingBottom: 0,
            paddingRight: 12,
            width: 0,
            height: 0
        )
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureGradientOverlay()
        configureActionButtons()
        
        addSubview(likeLabel)
        likeLabel.anchor(
            top: postImageView.bottomAnchor,
            left: nil,
            bottom: nil,
            right: postImageView.rightAnchor,
            paddingTop: -24,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 8,
            width: 0,
            height: 0
        )
        
        addSubview(captionLabel)
        captionLabel.anchor(
            top: postImageView.bottomAnchor,
            left: postImageView.leftAnchor,
            bottom: nil,
            right: likeLabel.leftAnchor,
            paddingTop: -24,
            paddingLeft: 12,
            paddingBottom: 0,
            paddingRight: 8,
            width: 0,
            height: 0
        )
    }
    
    //MARK: - Handlers
    
    @objc func handleFullnameTapped() {
        delegate?.handleFullnameTapped(for: self)
    }
    
    @objc func handleOptionsTapped() {
        delegate?.handleOptionsTapped(for: self)
    }
    
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(for: self)
    }
    
    @objc func handleCommentTapped() {
        delegate?.handleCommentTapped(for: self)
    }
    
    @objc func handleShowLikes() {
        delegate?.handleShowLikes(for: self)
    }
    
    func configureLikeButton() {
        delegate?.handleConfigureLikeButton(for: self)
    }
    
    func configureLikeLabel() {
        guard let post = self.post else { return }
        guard let likes = post.likes else { return }
        
        if likes == 1 {
            likeLabel.text = "\(likes) like"
        } else {
            likeLabel.text = "\(likes) likes"
        }
    }
    
    func configureCaption() {
        let caption = post?.caption ?? ""
        
        captionLabel.font = UIFont.boldSystemFont(ofSize: 12)
        captionLabel.textColor = .white
        captionLabel.text = caption
    }
    
    func configureGradientOverlay() {
        maskedView = UIView()
        maskedView.backgroundColor = .black
      
        postImageView.addSubview(maskedView)
          
        maskedView.translatesAutoresizingMaskIntoConstraints = false
      
        NSLayoutConstraint.activate([
            maskedView.heightAnchor.constraint(equalToConstant: 400),
            maskedView.leadingAnchor.constraint(equalTo: postImageView.leadingAnchor, constant: 0),
            maskedView.trailingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 0),
            maskedView.bottomAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 0)
        ])
    }
        
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let clearColor = UIColor.clear.withAlphaComponent(0.0).cgColor
        let whiteColor = UIColor.white.withAlphaComponent(0.5).cgColor
        
        let gradientMaskLayer = CAGradientLayer()
            gradientMaskLayer.frame = maskedView.bounds
            gradientMaskLayer.colors = [clearColor, clearColor, clearColor, whiteColor]
            gradientMaskLayer.locations = [0, 0.4, 0.6, 0.99]

        maskedView.layer.mask = gradientMaskLayer
    }
    
    func configureActionButtons() {
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, optionsButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 100, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
