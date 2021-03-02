//
//  CustomUIDelegate.swift
//  TabandNav
//
//  Created by Mac on 7/28/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import DKImagePickerController
import UIKit

open class CustomUIDelegate: DKImagePickerControllerBaseUIDelegate {
    override open func updateDoneButtonTitle(_ button: UIButton) {
        if self.imagePickerController.selectedAssets.count == 0 {
            button.setTitle(String(format: "Select", self.imagePickerController.selectedAssets.count), for: .normal)
            button.setTitleColor(.systemGray, for: .normal)
            button.isEnabled = false
        } else if self.imagePickerController.selectedAssets.count == 24 {
            button.setTitle("Done", for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.isEnabled = true
            button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: .touchUpInside)
        } else {
            button.setTitle("Select", for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.isEnabled = true
            button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: .touchUpInside)
        }
        button.sizeToFit()
    }
}
