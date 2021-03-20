//
//  UIViewController+StatusBar.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 3/20/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import UIKit

extension UIViewController {
    /// A helper function that can be called from any controller.
    /// Example: `navigationController?.setStatusBarAppearance()`.
    func setStatusBarAppearance(_ statusBarShouldBeHidden: Bool,
                                 statusBarAnimationStyle: UIStatusBarAnimation = .slide) {
        if let s = self as? BaseNavCon {
            s.statusBarShouldBeHidden = statusBarShouldBeHidden
            s.statusBarAnimationStyle = statusBarAnimationStyle
            s.updateStatusBarAppearance(completion: nil)
        }
    }
}
