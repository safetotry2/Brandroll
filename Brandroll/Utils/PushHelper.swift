//
//  PushHelper.swift
//  Brandroll
//
//  Created by Glenn Posadas on 9/19/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import Foundation

/**
 The helper used for interacting with defaults + firebase
 */
class PushHelper {
    /// Singleton manager.
    static let shared = PushHelper()

    /// Set the master switch - `allow-all` key to a new value on Firebase.
    /// This might be unnecessary for now as the device itself won't receive a push notif if its push Settings is set to disabled.
    func setAllowAllNotifications(_ shouldAllow: Bool) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        USER_NOTIF_PREF_REF
            .child(currentUid)
            .child(PREF_ALLOWALL_REF)
            .setValue(shouldAllow)
    }
    
    /// Sets the preferences on Firebase to all true, just once.
    /// Used in the start-up of the app. Called from the `AppDelegate`.
    func setAllNotificationsToOnOnce() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "setAllowAllNotificationsOnce") != true {
            defaults.setValue(true, forKey: "setAllowAllNotificationsOnce")
            
            setPref(true, notifType: .like)
            setPref(true, notifType: .comment)
            setPref(true, notifType: .follow)
            setPref(true, notifType: .message)
        }
    }
    
    /// Sets a specific preference.
    func setPref(_ isOn: Bool, notifType: AppNotif.NotificationType) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        USER_NOTIF_PREF_REF
            .child(currentUid)
            .child(notifType.firRef)
            .setValue(isOn)
    }
    
    /// Get the specific `isOn` value of a `notifType`.
    func getValueForNotifType(_ notifType: AppNotif.NotificationType,
                              block: @escaping ((_ isOn: Bool) -> Void?)) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            block(false)
            return
        }
        USER_NOTIF_PREF_REF
            .child(currentUid)
            .child(notifType.firRef)
            .observeSingleEvent(of: .value) { snapshot in
                block(snapshot.value as! Bool)
            }
    }
}

extension AppNotif.NotificationType {
    var firRef: String {
        switch self {
        case .like: return PREF_LIKES_REF
        case .comment: return PREF_COMMENTS_REF
        case .follow: return PREF_NEWFOLLOWERS_REF
        case .message: return PREF_DIRECTMESSAGES_REF
        }
    }
    
    init(withIntSwitchTag tag: Int) {
        self.init(index: tag)
    }
}

