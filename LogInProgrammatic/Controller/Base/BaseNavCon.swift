//
//  BaseNavCon.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 3/20/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import UIKit

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
