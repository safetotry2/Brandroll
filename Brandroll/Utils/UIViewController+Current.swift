//
//  UIViewController+Current.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 1/30/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import UIKit

var windowRootController: UIViewController? {
    if #available(iOS 13.0, *) {
        let windowScene = UIApplication.shared
            .connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first
        
        if let window = windowScene as? UIWindowScene {
            return window.windows.first?.rootViewController
        }
        
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
    } else {
        return UIApplication.shared.keyWindow?.rootViewController
    }
}

/// Category for any controller.
extension UIViewController {
    /// Class function to get the current or top most screen.
    class func current(controller: UIViewController? = windowRootController) -> UIViewController? {
        guard let controller = controller else { return nil }
        
        if let navigationController = controller as? UINavigationController {
            return current(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return current(controller: selected)
            }
        }
        if let presented = controller.presentedViewController {
            return current(controller: presented)
        }
        return controller
    }
}
