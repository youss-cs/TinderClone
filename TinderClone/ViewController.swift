//
//  ViewController.swift
//  TinderClone
//
//  Created by YouSS on 4/11/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let topStackView = HomeTopStackView()
    let blueView = UIView()
    let bottomStackView = HomeBottomStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
    }
    
    fileprivate func setupLayout() {
        blueView.backgroundColor = .blue
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, blueView, bottomStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }

}

