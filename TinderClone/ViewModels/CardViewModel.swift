//
//  CardViewModel.swift
//  TinderClone
//
//  Created by YouSS on 4/12/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

struct CardViewModel {
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(user: User, txtAlignment: NSTextAlignment = .left) {
        imageUrls = user.imageUrls
        
        let attrText = NSMutableAttributedString(string: "\(user.name) ", attributes: [.font : UIFont.systemFont(ofSize: 32, weight: .heavy)])
        attrText.append(NSAttributedString(string: "\(user.age) \n", attributes: [.font : UIFont.systemFont(ofSize: 24, weight: .regular)]))
        attrText.append(NSAttributedString(string: "\(user.profession)", attributes: [.font : UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        attributedString = attrText
        textAlignment = txtAlignment
    }
}
