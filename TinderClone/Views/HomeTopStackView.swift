//
//  HomeTopStackView.swift
//  TinderClone
//
//  Created by YouSS on 4/11/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

class HomeTopStackView: UIStackView {

    let settingsButton = UIButton(type: .system)
    let messageButton = UIButton(type: .system)
    let fireImageView = UIImageView(image: #imageLiteral(resourceName: "app_icon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        distribution = .equalCentering
        
        fireImageView.contentMode = .scaleAspectFit
        settingsButton.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)
        
        [settingsButton, fireImageView, messageButton].forEach { (view) in
            addArrangedSubview(view)
        }
        
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 32, bottom: 0, right: 32)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
