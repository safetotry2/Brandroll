//
//  Protocols.swift
//  LogInProgrammatic
//
//  Created by Mac on 10/14/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Foundation

protocol UserProfileHeaderDelegate: AnyObject {
    
    func handleEditProfileTapped(for header: UserProfileHeader)
    func handleSettingsTapped(for header: UserProfileHeader)
    func handleFollowButtonTapped(for header: UserProfileHeader)
    func handleMessageTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}

protocol FollowCellDelegate: AnyObject {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol FeedCellDelegate: AnyObject {
    func handleFullnameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell)
    func handleDoubleTapToLike(for cell: FeedCell)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
}

protocol CommentCellDelegate: AnyObject {
    func handleProfileImageTapped(for cell: CommentCell)
    func handleFullnameTapped(for cell: CommentCell)
}

protocol NotitificationCellDelegate: AnyObject {
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
}

protocol SearchProfileCellDelegate: AnyObject {
    func handleFollowTapped(for cell: SearchProfileCell, indexPath: IndexPath?)
}

protocol Printable {
    var description: String { get }
}

protocol CommentInputAccessoryViewDelegate: AnyObject {
    func didSubmit(forComment comment: String)
}

protocol ChatInputAccessoryViewDelegate: AnyObject {
    func didSubmit(forChat chat: String)
}
