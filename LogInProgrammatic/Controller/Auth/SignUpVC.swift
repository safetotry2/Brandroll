//
//  SignUpVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/9/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import SVProgressHUD
import UIKit

class SignUpVC: UIViewController {

    // MARK: - Properties
    
    var imageChanged = false
    
    let signUpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.text = "Sign up"
        return label
    }()
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.setLeftPaddingPoints(7)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.setLeftPaddingPoints(7)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Business name"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.autocapitalizationType = .words
        tf.autocorrectionType = .no
        tf.setLeftPaddingPoints(7)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let occupationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Occupation/Industry"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.autocapitalizationType = .words
        tf.autocorrectionType = .no
        tf.setLeftPaddingPoints(7)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
//    let usernameTextField: UITextField = {
//        let tf = UITextField()
//        tf.placeholder = "Username"
//        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
//        tf.borderStyle = .roundedRect
//        tf.font = UIFont.systemFont(ofSize: 14)
//        tf.autocapitalizationType = .none
//        tf.autocorrectionType = .no
//        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
//        return tf
//    }()
    
    let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(white: 0, alpha: 0.08)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
//    let alreadyhaveaccountButton: UIButton = {
//           let button = UIButton(type: .system)
//           let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
//           attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
//           button.setAttributedTitle(attributedTitle, for: .normal)
//           
//           button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
//           
//           return button
//       }()
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fullNameTextField.delegate = self
        occupationTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: Functions

    deinit {
        print("SignUp flow deallocated! ✅")
    }
        
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(signUpLabel)
        signUpLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
//        view.addSubview(plusPhotoButton)
//        plusPhotoButton.anchor(
//            top: signUpLabel.bottomAnchor, left: nil, bottom: nil, right: nil,
//            paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
//            width: 140, height: 140
//        )
        //plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        configureViewComponents()
//        view.addSubview(alreadyhaveaccountButton)
//        alreadyhaveaccountButton.anchor(
//            top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
//            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
//            width: 0, height: 50
//        )
    }
    
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [fullNameTextField, occupationTextField, emailTextField,  passwordTextField, signupButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(
            top: signUpLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor,
            paddingTop: 24, paddingLeft: 20, paddingBottom: 0, paddingRight: 20,
            width: 0, height: 310
        )
    }
    
    // MARK: - Selectors
    
    @objc func formValidation() {
        guard emailTextField.hasText,
        passwordTextField.hasText,
        fullNameTextField.hasText,
        occupationTextField.hasText
            else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor(white: 0, alpha: 0.08)
            signupButton.setTitleColor(.gray, for: .normal)
            return
            }
        signupButton.isEnabled = true
        signupButton.backgroundColor = .black
        signupButton.setTitleColor(.white, for: .normal)
    }
    
    @objc func handleSelectProfilePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        //present ImagePicker
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
//    @objc func handleShowLogin() {
//        _ = navigationController?.popViewController(animated: true)
//    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard error == nil else {
                SVProgressHUD.showError(withStatus: "Error signing up")
                print("Failed to create user with error", error!.localizedDescription)
                return
            }
            
            self.handleResult(result)
        }
    }
    
    // MARK: - API Calls
    
    private func handleResult(_ result: AuthDataResult?) {
        guard let fullName = fullNameTextField.text else { return }
        guard let occupation = occupationTextField.text else { return }
        //guard let username = usernameTextField.text?.lowercased() else { return }
        
        guard let uid = result?.user.uid else {
            SVProgressHUD.showError(withStatus: "User Id not found!")
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
                    "occupation": occupation
                    //"username": username
                ]
                var values = [uid: dictionaryValues]
                
                guard error == nil else {
                    print("Failed to upload image to Firebase Storage with error", error!.localizedDescription)
                    self.updateUserValues(values)
                    return
                }
                
                storageRef.downloadURL(completion: { (downloadURL, error) in
                    let profileImageUrl = downloadURL?.absoluteString ?? ""
                    dictionaryValues["profileImageUrl"] = profileImageUrl
                    values = [uid: dictionaryValues]
                    
                    self.updateUserValues(values)
                })
            }
        } else {
            // Create user without uploading a profile image.
            let dictionaryValues = [
                "name": fullName,
                "occupation": occupation
                //"username": username,
            ]
            let values = [uid: dictionaryValues]
            
            updateUserValues(values)
        }
    }
    
    private func updateUserValues(_ values: [String : Any]) {
        USER_REF.updateChildValues(values) { (error, ref) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Profile update failed!")
            } else {
                SVProgressHUD.showSuccess(withStatus: "")
            }
            
            // Inform RootVC.
            NotificationCenter.default.post(
                name: RootVC.didLoginNotification,
                object: nil
            )
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

// MARK: - UITextFieldDelegate

extension SignUpVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // check the textfield
        if textField == fullNameTextField || textField == occupationTextField {
            let maxLength = 36
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        // don't limit characters if textField is NOT `fullNameTextField` or `occupationTextField`
        return true
    }
}
