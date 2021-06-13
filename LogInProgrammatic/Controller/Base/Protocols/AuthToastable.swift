//
//  AuthToastable.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 6/13/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Foundation
import SnapKit

/**
 Auth controllers conform to this protocol for toastability.
 */
protocol AuthToastable: AnyObject {
    var toast: Toast? { get set }
    var constraint_FirstTextField: Constraint? { get set }
}

extension AuthToastable where Self: UIViewController {
    /// Show the error toast with text.
    /// - parameter text: The message string.
    /// - parameter upperReferenceView: the view that is located at the top of the toast.
    /// - parameter shouldUseSuperViewLeadingTrailing: a bool value to determine if the `upperReferenceView` has insets in its leading and trailing.
    func showErrorToast(_ text: String, upperReferenceView: UIView, shouldUseSuperViewLeadingTrailing: Bool = false) {
        if Thread.isMainThread {
            UIView.animate(withDuration: 0.3) {
                self.constraint_FirstTextField?.update(offset: 100)
            }
            toast = Toast(text: text)
            toast?.showAndAttachTo(upperReferenceView: upperReferenceView, shouldUseSuperViewLeadingTrailing: shouldUseSuperViewLeadingTrailing)
        } else {
            DispatchQueue.main.async {
                self.showErrorToast(text, upperReferenceView: upperReferenceView, shouldUseSuperViewLeadingTrailing: shouldUseSuperViewLeadingTrailing)
            }
        }
    }
    
    func hideToast() {
        if Thread.isMainThread {
            toast?.remove()
            toast = nil
            
            UIView.animate(withDuration: 0.3) {
                self.constraint_FirstTextField?.update(offset: 20)
            }
        } else {
            DispatchQueue.main.async {
                self.hideToast()
            }
        }
    }
}
