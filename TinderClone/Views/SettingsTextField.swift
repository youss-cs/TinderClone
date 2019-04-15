//
//  SettingsTextField.swift
//  TinderClone
//
//  Created by YouSS on 4/15/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

class SettingsTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 44)
    }
}
