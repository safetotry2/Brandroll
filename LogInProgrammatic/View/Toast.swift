//
//  Toast.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 6/13/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import SnapKit
import UIKit

protocol ToastDelegate: AnyObject {
    func userdidTapToast(_ toast: Toast, withData data: Any?)
}

class Toast: UIView {
    
    // MARK: - Properties
    
    private(set) var label: UILabel!
    private(set) var tapGesture: UITapGestureRecognizer!
    private(set) var data: Any?
    
    weak var delegate: ToastDelegate?
    
    // MARK: - Functions
    // MARK: Overrides
    
    init(bgColor: UIColor = .red,
         text: String,
         textColor: UIColor = .white,
         delegate: ToastDelegate? = nil,
         data: Any? = nil) {
        super.init(frame: .zero)
        
        isUserInteractionEnabled = true
        
        self.data = data
        self.delegate = delegate
        
        backgroundColor = bgColor
        
        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = text
        label.textColor = textColor
        label.numberOfLines = 0
        
        addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(25)
        }
        
        tapGesture = UITapGestureRecognizer(target: self,
                                            action: #selector(didTapSelf))
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func didTapSelf() {
        print("Tap Toast!")
        delegate?.userdidTapToast(self, withData: data)
    }
    
    func showAndAttachTo(upperReferenceView v: UIView, shouldUseSuperViewLeadingTrailing: Bool = false) {
        v.superview?.addSubview(self)
        
        self.snp.makeConstraints {
            $0.top.equalTo(v.snp.bottom)
            
            if shouldUseSuperViewLeadingTrailing {
                $0.leading.trailing.equalTo(v.superview!)
            } else {
                $0.leading.trailing.equalTo(v)
            }
        }
    }
    
    func remove() {
        label.text = ""
        removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
