//
//  CardViewModel.swift
//  TinderClone
//
//  Created by YouSS on 4/12/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit
import SDWebImage

class CardViewModel {
    let uid: String?
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(user: User, txtAlignment: NSTextAlignment = .left) {
        uid = user.uid
        var imgUrls = [String]()
        
        if let url = user.imageUrl1 { imgUrls.append(url) }
        if let url = user.imageUrl2 { imgUrls.append(url) }
        if let url = user.imageUrl3 { imgUrls.append(url) }
        
        imageUrls = imgUrls
        
        let ageString = user.age != nil ? "\(user.age!)" : "N\\A"
        let professionString = user.profession != nil ? user.profession! : "Not available"
        let attrText = NSMutableAttributedString(string: "\(user.fullName ?? "") ", attributes: [.font : UIFont.systemFont(ofSize: 32, weight: .heavy)])
        
        attrText.append(NSAttributedString(string: "\(ageString) \n", attributes: [.font : UIFont.systemFont(ofSize: 24, weight: .regular)]))
        attrText.append(NSAttributedString(string: professionString, attributes: [.font : UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        attributedString = attrText
        textAlignment = txtAlignment
    }
}
