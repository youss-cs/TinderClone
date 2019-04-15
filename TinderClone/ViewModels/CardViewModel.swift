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
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    var imageIndexObserver: ((Int, String?) -> ())?
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageURL = imageUrls[imageIndex]
            imageIndexObserver?(imageIndex, imageURL)
        }
    }
    
    init(user: User, txtAlignment: NSTextAlignment = .left) {
        imageUrls = [user.imageUrl1 ?? ""]
        
        let attrText = NSMutableAttributedString(string: "\(user.name ?? "") ", attributes: [.font : UIFont.systemFont(ofSize: 32, weight: .heavy)])
        attrText.append(NSAttributedString(string: "\(user.age ?? 0) \n", attributes: [.font : UIFont.systemFont(ofSize: 24, weight: .regular)]))
        attrText.append(NSAttributedString(string: "\(user.profession ?? "")", attributes: [.font : UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        attributedString = attrText
        textAlignment = txtAlignment
    }
    
    func goToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}
