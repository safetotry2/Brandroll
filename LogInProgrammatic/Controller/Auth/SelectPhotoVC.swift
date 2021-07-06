//
//  SelectPhotoVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 5/17/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import FirebaseStorage
import SVProgressHUD
import UIKit

class SelectPhotoVC: UIViewController {

    // MARK: - Properties
    
    var uid: String!
    var fullName: String!
    var occupation: String!
    
    let selectPhotoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.text = "Choose a profile photo"
        return label
    }()
    
    let optionalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = "(optional)"
        return label
    }()
    
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "circle").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "Business Name"
        return label
    }()
    
    let occupationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .lightGray
        label.text = "Occupation/Industry"
        return label
    }()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.backgroundColor = UIColor(red: 10/255, green: 25/255, blue: 49/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 5
        button.isEnabled = true
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        return button
    }()
    
    var imageChanged = false
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        assignValues()
    }
    
    private func assignValues() {
        nameLabel.text = fullName.condensedWhitespace
        occupationLabel.text = occupation.condensedWhitespace
    }
    
    // MARK: Functions
    
    @objc func handleSelectPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        //present ImagePicker
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        if imageChanged,
           let profileImage = self.selectPhotoButton.imageView?.image,
           let uploadData = profileImage.jpegData(compressionQuality: 0.3) {
            let filename = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            
            SVProgressHUD.show()
            
            storageRef.putData(uploadData, metadata: nil) { [unowned self] (metadata, error) in
                SVProgressHUD.dismiss()
                
                guard error == nil else {
                    print("Failed to upload image to Firebase Storage with error", error!.localizedDescription)
                    self.alert(title: "Error uploading profile image",
                          okayButtonTitle: "OK") { _ in
                            self.gotoHome()
                    }
                    return
                }
                
                storageRef.downloadURL(completion: { [unowned self] (downloadURL, error) in
                    let profileImageUrl = downloadURL?.absoluteString ?? ""
                    let imagedic = ["profileImageUrl": profileImageUrl]
                    self.updateUserValues(imagedic)
                })
            }
        } else {
            gotoHome()
        }
    }
    
    private func updateUserValues(_ values: [String : Any]) {
        USER_REF
            .child(uid!)
            .updateChildValues(values) { [unowned self] (error, ref) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Profile update failed!")
            } else {
                SVProgressHUD.showSuccess(withStatus: "")
            }
            
                self.gotoHome()
        }
    }
    
    private func gotoHome() {
        dismiss(animated: true) {
            // Inform RootVC.
            NotificationCenter.default.post(
                name: RootVC.didLoginNotification,
                object: nil
            )
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(selectPhotoLabel)
        selectPhotoLabel.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        selectPhotoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectPhotoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -300
        ).isActive = true
        
        view.addSubview(optionalLabel)
        optionalLabel.anchor(top: selectPhotoLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        optionalLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(selectPhotoButton)
        selectPhotoButton.anchor(top: optionalLabel.bottomAnchor, left: nil, bottom: nil, right: nil,
            paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
            width: 180, height: 180)
        selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: selectPhotoButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(occupationLabel)
        occupationLabel.anchor(top: nameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        occupationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(doneButton)
        doneButton.anchor(top: occupationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 80, paddingBottom: 0, paddingRight: 80, width: 0, height: 49)
    }

}

// MARK: - UIImagePickerControllerDelegate

extension SelectPhotoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // selected image
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        
        // upload profile image to Firebase at SignUp
        imageChanged = true
        selectPhotoButton.layer.cornerRadius = selectPhotoButton.frame.width / 2
        selectPhotoButton.layer.masksToBounds = true
        selectPhotoButton.layer.borderWidth = 0
        selectPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}
