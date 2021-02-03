//
//  SceneDelegate.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/8/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Setup HUD
        
        ProgressHUD.animationType = .circleStrokeSpin
        
        // Setup Firebase
        
        FirebaseApp.configure()
        
        // Setup Scene
        
        if window == nil {
            if let windowScene = scene as? UIWindowScene {
                let newWindow = UIWindow(windowScene: windowScene)
                self.window = newWindow
            }
        }
        
        window?.rootViewController = MainTabVC()
        window?.makeKeyAndVisible()
    }
}

