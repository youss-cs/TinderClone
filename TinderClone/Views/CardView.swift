//
//  CardView.swift
//  TinderClone
//
//  Created by YouSS on 4/11/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

protocol CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel)
    func didSwipe(didLike: Bool)
}

class CardView: UIView {
    
    fileprivate let thresHold: CGFloat = 80
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let barStackView = UIStackView()
    fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    fileprivate let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
    
    var nextCardView: CardView?
    var delegate: CardViewDelegate?
    
    var cardViewModel: CardViewModel! {
        didSet {
            swipingPhotosController.cardViewModel = self.cardViewModel
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageUrls.count).forEach { (_) in
                let view = UIView()
                view.backgroundColor = deselectedBarColor
                barStackView.addArrangedSubview(view)
            }
            barStackView.arrangedSubviews.first?.backgroundColor = .white
        }
    }
    
    let informationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    fileprivate let moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleMoreInfo), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLayout() {
        layer.cornerRadius = 16
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotosController.view!
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        
        setupGradienLayer()
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        
        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = frame
    }
    
    fileprivate func setupGradienLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
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
    
    @objc fileprivate func handleMoreInfo() {
        delegate?.didTapMoreInfo(cardViewModel: cardViewModel)
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
        
        if shouldDismissCard {
            let didLike = translationDirection == 1
            delegate?.didSwipe(didLike: didLike)
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.transform = .identity
            })
        }
    }
    
}
