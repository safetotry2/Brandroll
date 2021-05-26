//
//  SettingsVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 5/17/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import UIKit

class SettingsVC: UIViewController {

    // MARK: - Properties
    
    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log out", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        //button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViewComponents()
    }
    
    // MARK: - Functions

    func configureNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .white
        
        navigationItem.title = "Settings"
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleClose))
    }
    
    func configureViewComponents() {
        view.backgroundColor = .white
        
        view.addSubview(logoutButton)
        logoutButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 100, paddingRight: 0, width: 0, height: 0)
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func handleClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLogout() {
        // declare alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add alert logout action
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
                do {
                    // handle logout from tabController
                    if let tabBarController = self.tabBarController as? MainTabVC {
                        tabBarController.logout()
                    }
                    
                    // attempt sign out
                    try Auth.auth().signOut()
                    print("Successfully logged out user")
                    
                } catch {
                    // handle error
                    print("Failed to sign out")
                }
            
        }))
        
        // add cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    



}
