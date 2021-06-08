//
//  RootVC.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 2/20/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import UIKit

class RootVC: BaseVC {
    
    // MARK: - Properties
    
    static let didLogoutNotification = NSNotification.Name("didLogoutNotification")
    static let didLoginNotification = NSNotification.Name("didLoginNotification")
    
    private var didLoginNotification: NSNotification.Name {
        RootVC.didLoginNotification
    }
    
    private var didLogoutNotification: NSNotification.Name {
        RootVC.didLogoutNotification
    }
    
    private var currentlyPresentedFlow: UIViewController?
    
    // MARK: - Overrides
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkIfUserIsLoggedIn()
    }
    
    // MARK: - Observers
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dismissCurrentFlow),
            name: RootVC.didLoginNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dismissCurrentFlow),
            name: RootVC.didLogoutNotification,
            object: nil
        )
    }
    
    @objc private func dismissCurrentFlow() {
        currentlyPresentedFlow?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API
    
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            startAuthFlow()
        } else {
            startMainFlow()
        }
    }
    
    // MARK: - Flow
    
    private func startAuthFlow() {
        let welcomeVC = WelcomeVC()
        
        currentlyPresentedFlow = welcomeVC
        
        let navController = UINavigationController(rootViewController: welcomeVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true, completion: nil)
    }
    
    private func startMainFlow() {
        let mainTabVC = MainTabVC()
        
        currentlyPresentedFlow = mainTabVC
        
        mainTabVC.modalPresentationStyle = .fullScreen
        mainTabVC.modalTransitionStyle = .crossDissolve
        present(mainTabVC, animated: true, completion: nil)
    }
}
