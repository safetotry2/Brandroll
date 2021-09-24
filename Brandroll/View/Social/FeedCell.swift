//
//  FeedCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 10/26/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import Kingfisher
import SnapKit
import UIKit

class FeedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: FeedCellDelegate?
    
    private var maskedView: UIView!
    
    private lazy var centerHeart: UIImageView = {
        let i = UIImageView(image: UIImage(named: "heart_unfilled_white"))
        i.alpha = 0
        i.isHidden = true
        i.isUserInteractionEnabled = false
        i.applyDropShadow(withOffset: .zero, opacity: 0.5, radius: 0.5, color: .black)
        return i
    }()
    
    var post: Post? {
        didSet {            
            if let owner = post?.user {
                if let imageUrl = owner.profileImageUrl,
                   let url = URL(string: imageUrl) {
                    let resource = ImageResource(downloadURL: url)
                    self.profileImageView.kf.setImage(with: resource)
                } else if owner.profileImageUrl == nil {
                    profileImageView.image = #imageLiteral(resourceName: "circle")
                }
                
                self.fullnameButton.setTitle(owner.name ?? "", for: .normal)
                self.occupationLabel.text = owner.occupation ?? ""
                self.configureCaption(user: owner)
            }
            
            if let images = post?.images?.sorted(by: { $0.position < $1.position }),
               let firstImage = images.first,
               let url = URL(string: firstImage.imageUrl) {
                let resource = ImageResource(downloadURL: url)
                self.postImageView.kf.setImage(with: resource)
                
            } else if let imageUrl = post?.imageUrl,
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
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(postTap)
        iv.addGestureRecognizer(postTapTwice)
        return iv
    }()
    
    lazy var postTap: UITapGestureRecognizer = {
        // Single Tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        singleTap.numberOfTapsRequired = 1
        return singleTap
        
    }()
    
    lazy var postTapTwice: UITapGestureRecognizer = {
        // Double Tap
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTappedTwice))
        doubleTap.numberOfTapsRequired = 2
        postTap.require(toFail: doubleTap)
        return doubleTap
    }()
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "circle")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(profileImageTap)
        return iv
    }()
    
    lazy var profileImageTap: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleFullnameTapped))
        gesture.numberOfTapsRequired = 1
        return gesture
    }()
    
    lazy var fullnameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleFullnameTapped), for: .touchUpInside)
        return button
    }()
    
    let occupationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "heart_unfilled"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentMode = .center
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "quote"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
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
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    let postTimeLabel: UILabel =  {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 12)
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
            paddingLeft: 16,
            paddingBottom: 0,
            paddingRight: 16,
            width: 0,
            height: 0
        )
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureGradientOverlay()
        
        addSubview(profileImageView)
        profileImageView.anchor(top: postImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
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
        captionLabel.anchor(
            top: postImageView.bottomAnchor,
            left: postImageView.leftAnchor,
            bottom: nil,
            right: likeLabel.leftAnchor,
            paddingTop: -28,
            paddingLeft: 8,
            paddingBottom: 0,
            paddingRight: 8,
            width: 0,
            height: 0
        )
        
        addSubview(centerHeart)
        centerHeart.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.center.equalToSuperview()
        }
    }
    
    //MARK: - Handlers
    
    @objc func handlePostTapped() {
        guard let postImages = post?.images else { return }

        NotificationCenter.default.post(
            name: tappedPostCellImageNotificationKey,
            object: postImages,
            userInfo: nil
        )
    }
    
    @objc func handlePostTappedTwice() {
        delegate?.handleDoubleTapToLike(for: self)
        animateCenterHeart()
    }
    
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
    
    private func animateCenterHeart() {
        let likedScale: CGFloat = 1.5
        UIView.animate(withDuration: 0.1, animations: {
            self.centerHeart.alpha = 1
            self.centerHeart.isHidden = false
            self.centerHeart.transform = self.centerHeart.transform.scaledBy(x: likedScale, y: likedScale)
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                UIView.animate(withDuration: 0.1, animations: {
                    self.centerHeart.transform = CGAffineTransform.identity
                }, completion: { _ in
                    self.centerHeart.alpha = 0
                    self.centerHeart.isHidden = true
                })
            }
        })
    }
    
    func configureCaption(user: User?) {
        let caption = post?.caption ?? ""
        captionLabel.text = caption
        postTimeLabel.text = post?.creationDate.timeAgoToDisplay()
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
        stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 100, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    func applyDropShadow(withOffset offset: CGSize, opacity: Float, radius: CGFloat, color: UIColor) {
        layer.applyDropShadow(withOffset: offset, opacity: opacity, radius: radius, color: color)
    }
    
    func removeDropShadow() {
        layer.removeDropShadow()
    }
}

extension CALayer {
    func applyDropShadow(withOffset offset: CGSize, opacity: Float, radius: CGFloat, color: UIColor) {
        shadowOffset = offset
        shadowOpacity = opacity
        shadowRadius = radius
        shadowColor = color.cgColor
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
    }
    
    func removeDropShadow() {
        shadowOffset = .zero
        shadowOpacity = 0
        shadowRadius = 0
        shadowColor = UIColor.clear.cgColor
        shouldRasterize = false
    }
}
