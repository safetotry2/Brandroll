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
            if let owner = post?.user {
                if let imageUrl = owner.profileImageUrl,
                   let url = URL(string: imageUrl) {
                    let resource = ImageResource(downloadURL: url)
                    self.profileImageView.kf.setImage(with: resource)
                }
                
                self.fullnameButton.setTitle(owner.name ?? "", for: .normal)
                self.occupationLabel.text = owner.occupation ?? ""
                self.configureCaption(user: owner)
            }
            
            if let imageUrl = post?.imageUrl,
               let url = URL(string: imageUrl) {
                let resource = ImageResource(downloadURL: url)
                self.postImageView.kf.setImage(with: resource)
            }
            
            configureLikeLabel()
            configureLikeButton()
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
    
    let occupationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.text = "Occupation"
        return label
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
        
        // add gesture recognizer to label
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        likeTap.numberOfTouchesRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "Username", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 12)])
        
        attributedText.append(NSAttributedString(string: " Some test caption for now", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    let postTimeLabel: UILabel =  {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "2 DAYS AGO"
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 14, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureGradientOverlay()
        
        addSubview(profileImageView)
        profileImageView.anchor(top: postImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(fullnameButton)
        fullnameButton.anchor(top: postImageView.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: postImageView.bottomAnchor, left: fullnameButton.rightAnchor, bottom: nil, right: nil, paddingTop: 14, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(occupationLabel)
        occupationLabel.anchor(top: fullnameButton.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        configureActionButtons()
        
        addSubview(likeLabel)
        likeLabel.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: postImageView.rightAnchor, paddingTop: -24, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)

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
    
    func configureCaption(user: User?) {
        guard let post = self.post else { return }
        
        let caption = post.caption ?? ""
        let attributedText = NSMutableAttributedString(string: user?.username ?? "", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 12)])
        
        attributedText.append(NSAttributedString(string: " \(caption)", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]))
        
        captionLabel.attributedText = attributedText
        
        postTimeLabel.text = post.creationDate.timeAgoToDisplay()
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
