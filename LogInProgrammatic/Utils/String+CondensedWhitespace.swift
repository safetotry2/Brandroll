//
//  String+CondensedWhitespace.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 6/14/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Foundation

extension String {
    /// A variable that has a { get } of condensed whitespace.
    /// Example: Joining multiple strings not knowing if each string is empty or not.
    /// The output will be a cleaned up string. ("" "a" "" "b" -> a b)
    var condensedWhitespace: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
}
