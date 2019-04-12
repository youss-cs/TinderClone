//
//  CardView.swift
//  TinderClone
//
//  Created by YouSS on 4/11/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    let thresHold: CGFloat = 80
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            
            imageView.image = UIImage(named: user.imageUrl)
            
            let attibutedText = NSMutableAttributedString(string: "\(user.name) ", attributes: [.font : UIFont.systemFont(ofSize: 32, weight: .heavy)])
            attibutedText.append(NSAttributedString(string: "\(user.age) \n", attributes: [.font : UIFont.systemFont(ofSize: 30, weight: .regular)]))
            attibutedText.append(NSAttributedString(string: "\(user.profession)", attributes: [.font : UIFont.systemFont(ofSize: 24, weight: .regular)]))
            
            informationLabel.attributedText = attibutedText
        }
    }
    
    let imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    let informationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(imageView)
        addSubview(informationLabel)
        
        imageView.fillSuperview()
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default: break
        }
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let transition = gesture.translation(in: nil)
        let degree: CGFloat = transition.x / 20
        let angle = degree * .pi / 180
        
        transform = CGAffineTransform(rotationAngle: angle).translatedBy(x: transition.x, y: transition.y)
    }
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > thresHold
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            
            if shouldDismissCard {
                self.frame = CGRect(x: 600 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
            } else {
                self.transform = .identity
            }
        }, completion: { (_) in
            self.transform = .identity
            if shouldDismissCard {
                self.removeFromSuperview()
            }
        })
    }
    
}
