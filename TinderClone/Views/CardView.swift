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
    
    let imageView: UIImageView = {
        let img = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
        return img
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.fillSuperview()
        
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
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            
            if shouldDismissCard {
                self.frame = CGRect(x: 1000 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
            } else {
                self.transform = .identity
            }
        }, completion: { (_) in
            self.transform = .identity
            self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.width, height: self.superview!.frame.height)
        })
    }
    
}
