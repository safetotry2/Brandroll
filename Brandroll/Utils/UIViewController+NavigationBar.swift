//
//  UIViewController+NavigationBar.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 6/14/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import UIKit

extension UIViewController {
    /**
     Makes the navigation bar transparent, as if it's hidden.
     # Important Notes #
     - Adding a view behind the navbar could make the view untappable.
     */
    func makeNavBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    /**
     Resets the navigation bar's default attribute
     */
    func makeNavBarDefaultColor() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .`default`
        self.navigationController?.navigationBar.backgroundImage(for: .default)
        self.navigationController?.navigationBar.backgroundColor = .none
        self.navigationController?.navigationBar.setBackgroundImage(.none, for: .any, barMetrics: .default)
        self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
    }
}

