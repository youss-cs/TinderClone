//
//  UserDetailCell.swift
//  TinderClone
//
//  Created by YouSS on 4/17/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit
import SDWebImage

class UserDetailCell: UICollectionViewCell {
    
    var imageUrl: String? {
        didSet {
            guard let imageUrl = imageUrl else { return }
            if let url = URL(string: imageUrl) {
                imageView.sd_setImage(with: url)
            }
        }
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(imageView)
        imageView.fillSuperview()
    }
}
