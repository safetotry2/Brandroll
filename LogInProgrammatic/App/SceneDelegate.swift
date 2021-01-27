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
        
        // Setup Scene
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            FirebaseApp.configure()
            window.rootViewController = MainTabVC()
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

