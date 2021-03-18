//
//  Protocols.swift
//  LogInProgrammatic
//
//  Created by Mac on 10/14/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Foundation

protocol UserProfileHeaderDelegate: class {
    
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}

protocol FollowCellDelegate: class {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol FeedCellDelegate: class {
    func handleFullnameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
}

protocol CommentCellDelegate: class {
    func handleFullnameTapped(for cell: CommentCell)
}

protocol NotitificationCellDelegate: class {
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
}

protocol SearchProfileCellDelegate: class {
    func handleFollowTapped(for cell: SearchProfileCell)
}

protocol Printable {
    var description: String { get }
}

protocol CommentInputAccessoryViewDelegate: class {
    func didSubmit(forComment comment: String)
}

protocol ChatInputAccessoryViewDelegate: class {
    func didSubmit(forChat chat: String)
}
