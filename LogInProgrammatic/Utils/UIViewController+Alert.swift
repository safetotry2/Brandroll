//
//  UIViewController+Alert.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 2/20/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import UIKit

/// The completion callback for the `alert`.
public typealias AlertCallBack = ((_ userDidTapOk: Bool) -> Void)

/// Empty callback
public typealias EmptyCallBack = (() -> Void)

extension UIViewController {
    /**
     Presents an alertController with completion.
     - parameter title: The title of the alert.
     - parameter message: The body of the alert, nullable, since we can just sometimes use the title parameter.
     - parameter okButtonTitle: the title of the okay button.
     - parameter cancelButtonTitle: The title of the cancel button, defaults to nil, nullable.
     - parameter completion: The `AlertCallBack`, returns Bool. True when the user taps on the OK button, otherwise false.
     */
    public func alert(
        title: String,
        message: String? = nil,
        okayButtonTitle: String,
        cancelButtonTitle: String? = nil,
        withBlock completion: AlertCallBack?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: okayButtonTitle, style: .default) { _ in
            completion?(true)
        }
        alertController.addAction(okAction)
        
        if let cancelButtonTitle = cancelButtonTitle {
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .default) { _ in
                completion?(false)
            }
            alertController.addAction(cancelAction)
        }
        
        alertController.view.tintColor = .black
        present(alertController, animated: true, completion: nil)
    }
}
