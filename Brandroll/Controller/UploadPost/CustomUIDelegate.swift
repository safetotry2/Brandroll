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
        DispatchQueue.main.async {
            self.disableButton(button)
            
            if self.imagePickerController.selectedAssets.count == 0 {
                button.setTitle(String(format: "Select", self.imagePickerController.selectedAssets.count), for: .normal)
            } else if self.imagePickerController.selectedAssets.count == 24 {
                button.setTitle("Done", for: .normal)
                self.enableButton(button)
            } else {
                button.setTitle("Select", for: .normal)
                self.enableButton(button)
            }
            
            button.sizeToFit()
        }
    }
    
    private func enableButton(_ button: UIButton) {
        button.setTitleColor(.black, for: .normal)
        button.isUserInteractionEnabled = true
        button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: .touchUpInside)
    }
    
    private func disableButton(_ button: UIButton) {
        button.setTitleColor(.systemGray, for: .normal)
        button.isUserInteractionEnabled = false
        button.removeTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: .touchUpInside)
    }
}
