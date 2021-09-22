//
//  PushNotificationsVC.swift
//  Brandroll
//
//  Created by Glenn Posadas on 9/19/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import SnapKit
import UIKit

class PushNotificationsVC: BaseVC {
 
    // MARK: - Properties
    // MARK: - Enabled Views
    
    lazy var switchLikes = newSwitch(tag: 0)
    lazy var switchComments = newSwitch(tag: 1)
    lazy var switchNewFollowers = newSwitch(tag: 2)
    lazy var switchDirectMessages = newSwitch(tag: 3)
    
    lazy var separator1 = newSeparator()
    lazy var separator2 = newSeparator()
    lazy var separator3 = newSeparator()
    lazy var separator4 = newSeparator()
    
    lazy var labelLikes = newLabel(text: "Likes")
    lazy var labelComments = newLabel(text: "Comments")
    lazy var labelNewFollowers = newLabel(text: "New Followers")
    lazy var labelDirectMessages = newLabel(text: "Direct Messages")
    
    private lazy var containerSwitches = UIView()
    private lazy var containerInstructions = UIView()
    
    private lazy var loader: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.startAnimating()
        v.hidesWhenStopped = true
        v.isHidden = true
        return v
    }()
    
    // MARK: - Disabled views
    
    private lazy var instructionHeaderLabel = newLabel(text: "To receive push notifications, you'll need to turn them on in your iOS Settings.\nHere's how:")
    
    private lazy var settingsIcon: UIImageView = newIcon("ios_settings")
    private lazy var notificationsIcon: UIImageView = newIcon("ios_notifications")
    private lazy var toggleIcon: UIImageView = newIcon("ios_toggle")
    
    private lazy var settingsLabel = newLabel(text: "1. Go to Settings")
    private lazy var notificationsLabel = newLabel(text: "2. Tap \"Notifications\"")
    private lazy var toggleLabel = newLabel(text: "3. Turn on \"Allow Notifications\"")
    
    // MARK: - Functions
    
    private func newIcon(_ iconName: String) -> UIImageView {
        let i = UIImage(named: iconName)
        let iv = UIImageView(image: i)
        iv.contentMode = .scaleAspectFill
        return iv
    }
    
    private func newLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        label.text = text
        label.numberOfLines = 0
        return label
    }
    
    private func newSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        separator.alpha = 0.8
        return separator
    }
    
    private func newSwitch(tag: Int) -> UISwitch {
        let s = UISwitch()
        s.isOn = true
        s.onTintColor = .black
        s.tag = tag
        s.addTarget(self, action: #selector(prefSwitchChanged(_:)), for: .valueChanged)
        s.isEnabled = false
        return s
    }
    
    private lazy var gotoSettingsButton: UIButton = {
        let button = UIButton()
        button.setup("Go to Settings",
                     normalFont: UIFont.boldSystemFont(ofSize: 18),
                     normalTextColor: .white,
                     highlightedTextColor: .lightGray,
                     backgroundColor: UIColor.colorWithRGBHex(0x0B1325)
        )
        button.addTarget(self, action: #selector(handleGoToSettings), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.isEnabled = true
        return button
    }()
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        setupSwitchValues()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupSwitchValues() {
        PushHelper.shared.getValueForNotifType(.like) {
            self.setViewSwitchOn($0, notifType: .like)
        }
        PushHelper.shared.getValueForNotifType(.comment) {
            self.setViewSwitchOn($0, notifType: .comment)
        }
        PushHelper.shared.getValueForNotifType(.follow) {
            self.setViewSwitchOn($0, notifType: .follow)
        }
        PushHelper.shared.getValueForNotifType(.message) {
            self.setViewSwitchOn($0, notifType: .message)
        }
    }
    
    /// Set the switch views to `isOn` value and always set them to enabled.
    private func setViewSwitchOn(_ isOn: Bool, notifType: AppNotif.NotificationType) {
        switch notifType {
        case .like:
            self.switchLikes.isOn = isOn
            self.switchLikes.isEnabled = true
        case .comment:
            self.switchComments.isOn = isOn
            self.switchComments.isEnabled = true
        case .follow:
            self.switchNewFollowers.isOn = isOn
            self.switchNewFollowers.isEnabled = true
        case .message:
            self.switchDirectMessages.isOn = isOn
            self.switchDirectMessages.isEnabled = true
        }
    }
    
    @objc
    func prefSwitchChanged(_ sender: UISwitch) {
        let tag = sender.tag
        let isOn = sender.isOn
        let notifType = AppNotif.NotificationType(withIntSwitchTag: tag)
        PushHelper.shared.setPref(isOn, notifType: notifType)
    }
    
    @objc
    func applicationWillEnterForeground() {
        updateVisibilities()
    }
    
    @objc
    func handleGoToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
          return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
          UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
            
          })
        }
    }
    
    private func setupViews() {
        title = "Push Notifications"
        
        view.addSubview(loader)
        loader.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        containerSwitches.isHidden = true
        containerInstructions.isHidden = true
        
        setupDisabledPushNotifViews()
        setupEnabledPushNotifViews()
        
        updateVisibilities()
    }
    
    private func updateVisibilities() {
        notifIsEnabled { isEnabled in
            DispatchQueue.main.async {
                self.containerSwitches.isHidden = !isEnabled
                self.containerInstructions.isHidden = isEnabled
                PushHelper.shared.setAllowAllNotifications(isEnabled)
            }
        }
    }
    
    private func setupDisabledPushNotifViews() {
        view.addSubview(containerInstructions)
        containerInstructions.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(hasNotch ? 90 : 70)
            $0.height.equalTo(400)
        }
        
        containerInstructions.addSubview(instructionHeaderLabel)
        instructionHeaderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(50)
        }
        
        // Settings
        
        containerInstructions.addSubview(settingsIcon)
        settingsIcon.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.leading.equalTo(instructionHeaderLabel).offset(-10)
            $0.top.equalTo(instructionHeaderLabel.snp.bottom).offset(30)
        }
        
        containerInstructions.addSubview(settingsLabel)
        settingsLabel.snp.makeConstraints {
            $0.leading.equalTo(settingsIcon.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalTo(settingsIcon)
        }
        
        // Notif
        
        containerInstructions.addSubview(notificationsIcon)
        notificationsIcon.snp.makeConstraints {
            $0.width.height.leading.equalTo(settingsIcon)
            $0.top.equalTo(settingsIcon.snp.bottom).offset(20)
        }
        
        containerInstructions.addSubview(notificationsLabel)
        notificationsLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(settingsLabel)
            $0.centerY.equalTo(notificationsIcon)
        }
        
        // Toggle
        
        containerInstructions.addSubview(toggleIcon)
        toggleIcon.snp.makeConstraints {
            $0.width.height.equalTo(settingsIcon)
            $0.leading.equalTo(settingsIcon).offset(2)
            $0.top.equalTo(notificationsIcon.snp.bottom).offset(20)
        }
        
        containerInstructions.addSubview(toggleLabel)
        toggleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(settingsLabel)
            $0.centerY.equalTo(toggleIcon)
        }
        
        // Button
        
        containerInstructions.addSubview(gotoSettingsButton)
        gotoSettingsButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(toggleIcon.snp.bottom).offset(30)
        }
    }
    
    private func setupEnabledPushNotifViews() {
        view.addSubview(containerSwitches)
        containerSwitches.snp.makeConstraints {
            $0.top.equalToSuperview().inset(hasNotch ? 90 : 70)
          $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        let labels = [
            labelLikes,
            labelComments,
            labelNewFollowers,
            labelDirectMessages
        ]
        let stackView = UIStackView(arrangedSubviews: labels)
        
        labels.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(40)
            }
        }
        
        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        containerSwitches.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.top.leading.trailing.equalToSuperview().inset(30)
        }
        
        // Separators
        
        let offset: CGFloat = 8
        
        containerSwitches.addSubview(separator1)
        separator1.snp.makeConstraints {
            $0.top.equalTo(labelLikes.snp.bottom).offset(offset)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(1)
        }

        containerSwitches.addSubview(separator2)
        separator2.snp.makeConstraints {
            $0.top.equalTo(labelComments.snp.bottom).offset(offset)
            $0.leading.trailing.height.equalTo(separator1)
        }

        containerSwitches.addSubview(separator3)
        separator3.snp.makeConstraints {
            $0.top.equalTo(labelNewFollowers.snp.bottom).offset(offset)
            $0.leading.trailing.height.equalTo(separator1)
        }

        containerSwitches.addSubview(separator4)
        separator4.snp.makeConstraints {
            $0.top.equalTo(labelDirectMessages.snp.bottom).offset(offset)
            $0.leading.trailing.height.equalTo(separator1)
        }
        
        // Switches
        
        containerSwitches.addSubview(switchLikes)
        switchLikes.snp.makeConstraints {
            $0.centerY.equalTo(labelLikes)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        containerSwitches.addSubview(switchComments)
        switchComments.snp.makeConstraints {
            $0.centerY.equalTo(labelComments)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        containerSwitches.addSubview(switchNewFollowers)
        switchNewFollowers.snp.makeConstraints {
            $0.centerY.equalTo(labelNewFollowers)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        containerSwitches.addSubview(switchDirectMessages)
        switchDirectMessages.snp.makeConstraints {
            $0.centerY.equalTo(labelDirectMessages)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    typealias NotifIsEnabled = ((_ notifIsDisabled: Bool) -> Void)?
    private func notifIsEnabled(block: NotifIsEnabled) {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { permission in
            let isEnabled = permission.authorizationStatus == .authorized
                || permission.authorizationStatus == .provisional
            block?(isEnabled)
        })
    }
}
