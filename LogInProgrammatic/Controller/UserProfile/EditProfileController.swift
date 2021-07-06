//
//  EditProfileController.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/26/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import Kingfisher
import UIKit

class EditProfileController: UIViewController {
    
    // MARK: - Properties
    
    var user: User?
    var imageChanged = false
    var fullnameChanged = false
    var occupationChanged = false
    var bioChanged = false
    var userProfileController: UserProfileVC?
    var updatedFullname: String?
    var updatedOccupation: String?
    var updatedBio: String?
        
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "circle")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        //iv.backgroundColor = .lightGray
        
        // add gesture recognizer to image
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(handleChangeProfilePhoto))
        profileTap.numberOfTouchesRequired = 1
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(profileTap)
        
        return iv
    }()
    
    let fullnameTextField: UITextField = {
        let tf = UITextField()
        let borderColor = UIColor.lightGray
        tf.textAlignment = .center
        tf.layer.cornerRadius = 40 / 5
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = borderColor.cgColor
        return tf
    }()
    
    let occupationTextField: UITextField = {
        let tf = UITextField()
        let borderColor = UIColor.lightGray
        tf.textAlignment = .center
        tf.layer.cornerRadius = 40 / 5
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = borderColor.cgColor
        return tf
    }()
    
    let bioTextView: UITextView = {
        let tv = UITextView()
        let borderColor = UIColor.lightGray

        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textAlignment = .left
        tv.layer.cornerRadius = 8
        tv.textContainer.maximumNumberOfLines = 6
        tv.isScrollEnabled = false
        let padding = tv.textContainer.lineFragmentPadding
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tv.layer.borderColor = borderColor.cgColor
        tv.layer.borderWidth = 0.5
        return tv
    }()
    
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Business Name"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    let occupationLabel: UILabel = {
        let label = UILabel()
        label.text = "Occupation/Industry"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "Bio"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureViewComponents()
        
        fullnameTextField.delegate = self
        occupationTextField.delegate = self
        bioTextView.delegate = self
        
        loadUserData()
    }
    
    
    // MARK: - Handlers
    
    @objc func handleChangeProfilePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        view.endEditing(true)
        
        if fullnameChanged {
            updateFullname()
        }
        
        if occupationChanged {
            updateOccupation()
        }

        if bioChanged {
            updateBio()
        }
        
        if imageChanged {
            updateProfileImage()
        }
    }
    
    func loadUserData() {
        guard let user = self.user else { return }

        if let imageUrl = user.profileImageUrl,
           let url = URL(string: imageUrl) {
            let resource = ImageResource(downloadURL: url)
            profileImageView.kf.setImage(with: resource)
            
        }
        
        fullnameTextField.text = user.name
        occupationTextField.text = user.occupation
        bioTextView.text = user.bio
    }
    
    func configureViewComponents() {
        
        view.backgroundColor = .white

        let frame = CGRect(x: 0, y: 66, width: view.frame.width, height: 150)
        let containerView = UIView(frame: frame)
        containerView.backgroundColor = UIColor.white

        view.addSubview(containerView)
        
        containerView.addSubview(profileImageView)
        profileImageView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 140 / 2
        
        view.addSubview(fullnameLabel)
        fullnameLabel.anchor(top: containerView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        fullnameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(fullnameTextField)
        fullnameTextField.anchor(top: fullnameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: (view.frame.width / 1.2), height: 40)
        fullnameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(occupationLabel)
        occupationLabel.anchor(top: fullnameTextField.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        occupationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(occupationTextField)
        occupationTextField.anchor(top: occupationLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: (view.frame.width / 1.2), height: 40)
        occupationTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(bioLabel)
        bioLabel.anchor(top: occupationTextField.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        bioLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(bioTextView)
        bioTextView.anchor(top: bioLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: (view.frame.width / 1.2), height: 140)
        bioTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func configureNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .white
        
        navigationItem.title = "Edit Profile"
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.frame.origin.y = 0
            }, completion: nil)
        }
    }
    
    // MARK: - API
    
    func updateFullname() {
        guard let updatedFullname = self.updatedFullname else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard fullnameChanged == true else { return }
        
        USER_REF.child(currentUid).child("name").setValue(updatedFullname) { (err, ref) in
            
            guard let userProfileController = self.userProfileController else { return }
            userProfileController.fetchCurrentUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateOccupation() {
        guard let updatedOccupation = self.updatedOccupation else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard occupationChanged == true else { return }
        
        USER_REF.child(currentUid).child("occupation").setValue(updatedOccupation) { (err, ref) in
            
            guard let userProfileController = self.userProfileController else { return }
            userProfileController.fetchCurrentUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateBio() {
        guard let updatedBio = self.updatedBio else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard bioChanged == true else { return }
        
        USER_REF.child(currentUid).child("bio").setValue(updatedBio) { (err, ref) in
            
            guard let userProfileController = self.userProfileController else { return }
            userProfileController.fetchCurrentUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
 
    func updateProfileImage() {
        
        guard imageChanged == true else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        if let profileImageURL = user.profileImageUrl {
            Storage.storage().reference(forURL: profileImageURL).delete(completion: nil)
        }
        
        let filename = NSUUID().uuidString
        guard let updatedProfileImage = profileImageView.image else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images").child(filename)
        guard let imageData = updatedProfileImage.jpegData(compressionQuality: 0.3) else { return }
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                print("Failed to upload image to storage with error: ", error.localizedDescription)
            }
            
            storageRef.downloadURL { (downloadURL, error) in
                
                guard let updatedProfileImageUrl = downloadURL?.absoluteString else { return }
                USER_REF.child(currentUid).child("profileImageUrl").setValue(updatedProfileImageUrl) { (err, ref) in
                    
                    guard let userProfileController = self.userProfileController else { return }
                    userProfileController.fetchCurrentUserData()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
        
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            profileImageView.image = selectedImage
            self.imageChanged = true
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension EditProfileController: UITextFieldDelegate, UITextViewDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == fullnameTextField || textField == occupationTextField {
            let maxLength = 36
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        // don't limit characters if textField is NOT `fullNameTextField` or `occupationTextField`
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let user = self.user else { return }
        
        let fullnameTrimmedString = fullnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let occupationTrimmedString = occupationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if user.name == fullnameTrimmedString {
            fullnameChanged = false
        } else {
            fullnameChanged = true
            updatedFullname = fullnameTrimmedString
        }
        
        if user.occupation == occupationTrimmedString {
            occupationChanged = false
        } else {
            occupationChanged = true
            updatedOccupation = occupationTrimmedString
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 234
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//
//        if self.view.frame.origin.y == 0 {
//            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseOut, animations: {
//                self.view.frame.origin.y -= 120
//            }, completion: nil)
//        }
//    }
    
    func textViewDidEndEditing(_ textField: UITextView) {
        
        guard let user = self.user else { return }

        let bioTrimmedString = bioTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if user.bio == bioTrimmedString {
            bioChanged = false
        } else {
            bioChanged = true
            updatedBio = bioTrimmedString
        }
    }
    
}








// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
