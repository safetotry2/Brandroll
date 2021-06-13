//
//  Error+PresentableMessage.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 6/13/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import Foundation

extension Error {
    var presentableMessage: String {
        let nsError = self as NSError
        let code = nsError.code
        
        if let firAuthErrorCode = AuthErrorCode(rawValue: code) {
            switch firAuthErrorCode {
            case .userNotFound, .wrongPassword:
                return "The password or email address you entered is incorrect. Contact us if you are having trouble logging in."
            default:
                break
            }
        }
        
        return "Unable to sign user in with error \(localizedDescription)"
    }
}
