//
//  CardView.swift
//  TinderClone
//
//  Created by YouSS on 4/11/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    fileprivate let thresHold: CGFloat = 80
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let barStackView = UIStackView()
    fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    
    var cardViewModel: CardViewModel! {
        didSet {
            if let url = URL(string: cardViewModel.imageUrls.first ?? "") {
                imageView.sd_setImage(with: url)
            }
            
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            setupImageIndexObserver()
            
            (0..<cardViewModel.imageUrls.count).forEach { (_) in
                let view = UIView()
                view.backgroundColor = deselectedBarColor
                barStackView.addArrangedSubview(view)
            }
            barStackView.arrangedSubviews.first?.backgroundColor = .white
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
        
        setupLayout()
        setupBarStackView()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLayout() {
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.fillSuperview()
        
        setupGradienLayer()
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = frame
    }
    
    fileprivate func setupGradienLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }
    
    fileprivate func setupBarStackView() {
        barStackView.distribution = .fillEqually
        barStackView.spacing = 4
        addSubview(barStackView)
        barStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }
    
    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { (index, image) in
            self.barStackView.arrangedSubviews.forEach { (view) in
                view.backgroundColor = self.deselectedBarColor
            }
            self.barStackView.arrangedSubviews[index].backgroundColor = .white
            self.imageView.image = image
        }
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default: break
        }
    }
    
    var imageIndex = 0
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: nil)
        let shouldMoveNextPhoto = location.x > self.frame.width / 2 ? true : false
        
        if shouldMoveNextPhoto {
            cardViewModel.goToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
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
