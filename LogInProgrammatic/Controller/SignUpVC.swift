//
//  SignUpVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/9/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {

    // MARK: - Properties
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        //Secure text entry for password
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let occupationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Occupation"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyhaveaccountButton: UIButton = {
           let button = UIButton(type: .system)
           let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
           attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
           button.setAttributedTitle(attributedTitle, for: .normal)
           
           button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
           
           return button
       }()
    
    var imageChanged = false
    
    // MARK: - Overrides
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil,
            paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
            width: 140, height: 140
        )
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        configureViewComponents()
        view.addSubview(alreadyhaveaccountButton)
        alreadyhaveaccountButton.anchor(
            top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
            width: 0, height: 50
        )
    }
    
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, occupationTextField, usernameTextField, passwordTextField, signupButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(
            top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor,
            paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40,
            width: 0, height: 240
        )
    }
    
    // MARK: - Selectors
    
    @objc func formValidation() {
        guard emailTextField.hasText,
        passwordTextField.hasText,
        fullNameTextField.hasText,
        occupationTextField.hasText,
        usernameTextField.hasText else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        signupButton.isEnabled = true
        signupButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    @objc func handleSelectProfilePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        //present ImagePicker
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        ProgressHUD.show("Please wait...", interaction: false)
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard error != nil else {
                ProgressHUD.showError("Error signing up")
                print("Failed to create user with error", error!.localizedDescription)
                return
            }
            
            ProgressHUD.show("Updating your profile...", interaction: false)
            self.handleResult(result)
        }
    }
    
    // MARK: - API Calls
    
    private func handleResult(_ result: AuthDataResult?) {
        guard let fullName = fullNameTextField.text else { return }
        guard let occupation = occupationTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        
        guard let uid = result?.user.uid else {
            ProgressHUD.showError("User Id not found!")
            return
        }
        
        if imageChanged,
           let profileImage = self.plusPhotoButton.imageView?.image,
           let uploadData = profileImage.jpegData(compressionQuality: 0.3) {
            let filename = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                var dictionaryValues = [
                    "name": fullName,
                    "occupation": occupation,
                    "username": username
                ]
                let values = [uid: dictionaryValues]
                
                guard error != nil else {
                    print("Failed to upload image to Firebase Storage with error", error!.localizedDescription)
                    self.updateUserValues(values)
                    return
                }
                
                storageRef.downloadURL(completion: { (downloadURL, error) in
                    let profileImageUrl = downloadURL?.absoluteString ?? ""
                    dictionaryValues["profileImageUrl"] = profileImageUrl

                    self.updateUserValues(values)
                })
            }
        } else {
            // Create user without uploading a profile image.
            let dictionaryValues = [
                "name": fullName,
                "occupation": occupation,
                "username": username,
            ]
            let values = [uid: dictionaryValues]
            
            updateUserValues(values)
        }
    }
    
    private func updateUserValues(_ values: [String : Any]) {
        USER_REF.updateChildValues(values) { (error, ref) in
            if error != nil {
                ProgressHUD.showFailed("Profile update failed!")
            } else {
                ProgressHUD.showSucceed()
            }
            
            let mainTabVC = UIApplication.shared.windows.filter({$0.isKeyWindow})
                .first?.rootViewController as? MainTabVC
            mainTabVC?.configureViewControllers()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // selected image
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        
        // configure plusPhotoButton with selected image
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        // upload profile image to Firebase at SignUp
        imageChanged = true
        
        dismiss(animated: true, completion: nil)
    }
}
