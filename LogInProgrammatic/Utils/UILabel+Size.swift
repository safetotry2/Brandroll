//
//  UILabel+Size.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 6/14/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import UIKit

extension UILabel {
    func getSize(constrainedWidth: CGFloat) -> CGSize {
        return systemLayoutSizeFitting(CGSize(width: constrainedWidth, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}
