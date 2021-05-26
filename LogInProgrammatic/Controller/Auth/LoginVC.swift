//
//  LoginVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/8/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    // MARK: - Properties
    
//    let selectPhotoButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Select Photo VC", for: .normal)
//        button.setTitleColor(.gray, for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
//        return button
//    }()
    
    let logoContainerBGColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
    
    lazy var extraSafeAreaTopView: UIView = {
        let view = UIView()
        view.backgroundColor = logoContainerBGColor
        return view
    }()
    
    lazy var logoContainerView: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = logoContainerBGColor
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email address"
        //tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.setLeftPaddingPoints(7)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
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
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(white: 0, alpha: 0.08)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handlelogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
//    let forgotPasswordButton: UIButton = {
//        let button = UIButton(type: .system)
//        let attributedTitle = NSMutableAttributedString(string: "Forgot your password?", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray])
//        button.setAttributedTitle(attributedTitle, for: .normal)
//        button.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
//        return button
//    }()
    
//    let donthaveaccountButton: UIButton = {
//        let button = UIButton(type: .system)
//        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
//        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
//        button.setAttributedTitle(attributedTitle, for: .normal)
//
//        button.addTarget(self, action: #selector(handleShowSignup), for: .touchUpInside)
//
//        return button
//    }()
    
    // MARK: Overrides
    
    deinit {
        print("Login flow deallocated! ✅")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background color
        view.backgroundColor = .white
        
        //hide nav bar
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
            width: 0, height: 150
        )
        
        view.addSubview(extraSafeAreaTopView)
        extraSafeAreaTopView.anchor(
            top: view.topAnchor, left: view.leftAnchor, bottom: logoContainerView.topAnchor, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
            width: 0, height: 150
        )
        
        configureViewComponents()
        
//        view.addSubview(donthaveaccountButton)
//        donthaveaccountButton.anchor(
//            top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
//            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
//            width: 0, height: 50
//        )
        
    }
    
    // MARK: - Functions
    
//    @objc func handleSelectPhoto() {
//        let selectPhoto = SelectPhotoVC()
//        navigationController?.pushViewController(selectPhoto, animated: true)
//    }
    
//    @objc func handleShowSignup() {
//        let signUpVC = SignUpVC()
//        navigationController?.pushViewController(signUpVC, animated: true)
//    }
    
//    @objc func handleForgotPassword() {
//        print("Handle Forgot Password")
//    }
    
    @objc func handlelogin() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        // sign user in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            // handle error
            if let error = error {
                print("Unable to sign user in with error", error.localizedDescription)
                self.alert(
                    title: "Error",
                    message: "Unable to sign user in with error: \(error.localizedDescription)",
                    okayButtonTitle: "OK",
                    withBlock: nil
                )
                return
            }
            
            print("Succesfully logged in user")
            
            // Inform RootVC.
            NotificationCenter.default.post(
                name: RootVC.didLoginNotification,
                object: nil
            )
        }
    }
    
    @objc func formValidation() {
        // ensures that email and password text fields have text
        guard
        emailTextField.hasText,
        passwordTextField.hasText
            else {
                // handle cases for above conditions not met
                loginButton.isEnabled = false
                loginButton.backgroundColor = UIColor(white: 0, alpha: 0.08)
                loginButton.setTitleColor(.gray, for: .normal)
                return
            }
        // handle cases for conditions were met
        loginButton.isEnabled = true
        loginButton.backgroundColor = .black
        loginButton.setTitleColor(.white, for: .normal)
    }
    
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 180)
        
//        view.addSubview(forgotPasswordButton)
//        forgotPasswordButton.anchor(top: stackView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//
//        view.addSubview(selectPhotoButton)
//        selectPhotoButton.anchor(top: forgotPasswordButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
