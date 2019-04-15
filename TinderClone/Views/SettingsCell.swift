//
//  SettingsCell.swift
//  TinderClone
//
//  Created by YouSS on 4/15/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    let textField: UITextField = {
        let tf = SettingsTextField()
        tf.placeholder = "Enter Name"
        return tf
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(textField)
        textField.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}

