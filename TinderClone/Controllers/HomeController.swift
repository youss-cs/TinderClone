//
//  HomeController.swift
//  TinderClone
//
//  Created by YouSS on 4/11/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

class HomeController: UIViewController {

    let topStackView = HomeTopStackView()
    let cardsDeckView = UIView()
    let bottomStackView = HomeBottomStackView()
    
    let users = [
        User(name: "Kelly", age: 23, profession: "Music DJ", imageUrl: "lady5c"),
        User(name: "Jane", age: 18, profession: "Teacher", imageUrl: "lady4c")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupCardsDeck()
    }
    
    fileprivate func setupLayout() {
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
    fileprivate func setupCardsDeck() {
        users.forEach { (user) in
            let cardView = CardView()
            cardView.cardViewModel = CardViewModel(user: user)
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
            
        }
    }

}

