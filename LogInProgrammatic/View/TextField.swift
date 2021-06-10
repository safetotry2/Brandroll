//
//  TextField.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 6/10/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import UIKit

class TextField: UITextField {
    
    // MARK: - Properties
    
    private(set) var hasBeenEdited: Bool = false
    private(set) var errorMessage: String = ""
    private(set) var errorColor: UIColor!
    
    private var errorLabel: UILabel!
    private var borderView: UIView!
        
    // MARK: - Functions
    // MARK: Overrides
    
    init(errorMessage: String, errorColor: UIColor = .red) {
        super.init(frame: .zero)
        
        self.errorMessage = errorMessage
        self.errorColor = errorColor
        
        layout()
    }
    
    private func layout() {
        borderView = UIView()
        borderView.backgroundColor = .clear
        borderView.layer.borderColor = errorColor.cgColor
        borderView.layer.borderWidth = 1
        borderView.layer.cornerRadius = 4
        borderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderView)
        
        borderView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        borderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        
        errorLabel = UILabel()
        errorLabel.text = errorMessage
        errorLabel.textColor = errorColor
        errorLabel.font = UIFont.systemFont(ofSize: 10)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorLabel)
        
        errorLabel.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 4).isActive = true
        errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        sendSubviewToBack(borderView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        hasBeenEdited = true
        return true
    }
}
