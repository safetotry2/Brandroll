//
//  LoginVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/8/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import SnapKit
import UIKit

class LoginVC: UIViewController, AuthToastable {
    
    // MARK: - Properties
    
    var toast: Toast?
    var constraint_FirstTextField: Constraint?
    
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
  
    /// A quick hack for fixing the iOS 13 or earlier issue in `DTTextField` wherein the first textField becomes smaller.
    lazy var dummyTextField: DTTextField = {
        let tf = DTTextField()
        tf.placeholder = "Dummy TextField"
        tf.isHidden = true
        return tf
    }()
    
    lazy var emailTextField: DTTextField = {
        let tf = DTTextField()
        tf.placeholder = "Email address"
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        
        tf.floatingDisplayStatus = .never
        tf.dtborderStyle = .rounded
        tf.delegate = self
        
        tf.addTarget(self, action: #selector(formValidation(_:)), for: .editingChanged)
        return tf
    }()
    
    lazy var passwordTextField: DTTextField = {
        let tf = DTTextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        
        tf.floatingDisplayStatus = .never
        tf.dtborderStyle = .rounded
        tf.delegate = self
        
        tf.addTarget(self, action: #selector(formValidation(_:)), for: .editingChanged)
        return tf
    }()
    
    lazy var textFields: [DTTextField] = {
        return [emailTextField, passwordTextField]
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
    
    // MARK: Overrides
    
    deinit {
        print("Login flow deallocated! ✅")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background color
        view.backgroundColor = .white
                
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
    }
    
    // MARK: - Functions
    
    @objc func handlelogin() {
        guard let email = emailTextField.text?.replacingOccurrences(of: " ", with: ""),
              let password = passwordTextField.text else { return }
        
        hideToast()
        
        // sign user in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] (user, error) in
            // handle error
            if let error = error {
                self.showErrorToast(error.presentableMessage, upperReferenceView: logoContainerView)
                print("Unable to sign user in with error", error.localizedDescription)
                
                if error.userNotFoundOrWrongPassword {
                    toggleLoginButtonState(enabled: false)
                }
                
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
    
    func configureViewComponents() {
        view.addSubview(dummyTextField)
        dummyTextField.snp.makeConstraints {
            constraint_FirstTextField = $0.top.equalTo(logoContainerView.snp.bottom).offset(20).constraint
            $0.leading.trailing.equalToSuperview().inset(20)
        }
      
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints {
            constraint_FirstTextField = $0.top.equalTo(logoContainerView.snp.bottom).offset(20).constraint
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(emailTextField)
            $0.top.equalTo(emailTextField.snp.bottom).offset(16)
        }
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.trailing.equalTo(emailTextField)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(16)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let dtTxtField = textField as? DTTextField else {
            return true
        }
        
        if dtTxtField.hasEdited && !dtTxtField.hasValidValue {
            dtTxtField.showError(message: "This field is required.")
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard let dtTxtField = textField as? DTTextField else {
            return true
        }
        
        if dtTxtField.hasEdited {
            dtTxtField.showError(message: "This field is required.")
            hideToast()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let dtTxtField = textField as? DTTextField else {
            return true
        }
        
        dtTxtField.hasEdited = true
        
        return true
    }
    
    @objc func formValidation(_ textField: DTTextField) {
        checkContentsAndToggleButtonState()
        
        if textField.hasEdited {
            if !textField.hasText {
                textField.showError(message: "This field is required.")
            }
        }
    }
    
    private func checkContentsAndToggleButtonState() {
        // ensures that email and password text fields have text
        guard
            emailTextField.hasText,
            passwordTextField.hasText,
            emailTextField.hasValidValue,
            passwordTextField.hasValidValue
        else {
            // handle cases for above conditions not met
            toggleLoginButtonState(enabled: false)
            return
        }
            
        // handle cases for conditions were met
        hideToast()
        toggleLoginButtonState(enabled: true)
    }
    
    private func toggleLoginButtonState(enabled: Bool) {
        if enabled {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .black
            loginButton.setTitleColor(.white, for: .normal)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(white: 0, alpha: 0.08)
            loginButton.setTitleColor(.gray, for: .normal)
        }
    }
}
