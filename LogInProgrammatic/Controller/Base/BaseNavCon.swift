//
//  BaseNavCon.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 3/20/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import UIKit

/**
 This base navigationController class conforms to `StatusBarToggelable` protocol.
 We can set the statusBar states (ie visibility, and animation style) by using navCon init method.
 We can also set it by using the extension method `setStatusBarAppearance` of `UIViewController`.
 The reason why we put everything in the navCon subclass is that ideally and most of the time, we embed the controller
 in a navCon even if our controller has no navBar.
 */
class BaseNavCon: UINavigationController, StatusBarToggleable {
    
    // MARK: - Properties
    
    var statusBarShouldBeHidden: Bool = false
    var statusBarAnimationStyle: UIStatusBarAnimation = .slide
    
    override var prefersStatusBarHidden: Bool { statusBarShouldBeHidden }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { statusBarAnimationStyle }
    
    // MARK: - Functions
    // MARK: Overrides

    convenience init(
        rootViewController: UIViewController,
        statusBarShouldBeHidden: Bool = false,
        statusBarAnimationStyle: UIStatusBarAnimation = .slide) {
        
        self.init(rootViewController: rootViewController)
        self.statusBarShouldBeHidden = statusBarShouldBeHidden
        self.statusBarAnimationStyle = statusBarAnimationStyle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateStatusBarAppearance(completion: nil)
    }
}
