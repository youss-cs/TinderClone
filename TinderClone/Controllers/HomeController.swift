//
//  HomeController.swift
//  TinderClone
//
//  Created by YouSS on 4/11/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController {

    let topStackView = HomeTopStackView()
    let cardsDeckView = UIView()
    let bottomStackView = HomeBottomStackView()
    var cardViewModels = [CardViewModel]()
    var lastFetchUser: User?
    
    /*let users = [
        User(name: "Kelly", age: 23, profession: "Music DJ", imageUrls: ["jane1","jane2","jane3"]),
        User(name: "Jane", age: 18, profession: "Teacher", imageUrls: ["kelly1","kelly2","kelly3"])
    ]*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        setupLayout()
        fetchUsers()
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
    
    fileprivate func fetchUsers() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Users"
        hud.show(in: view)
        
        let query = Firestore.firestore().collection("Users").order(by: "uid").start(after: [lastFetchUser?.id ?? ""]).limit(to: 2)
        query.getDocuments { (snapshot, error) in
            hud.dismiss()
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let user = User(dictionary: documentSnapshot.data())
                let cardViewModel = CardViewModel(user: user)
                self.cardViewModels.append(cardViewModel)
                self.setupUserCard(cardViewModel)
                self.lastFetchUser = user
            })
        }
    }
    
    fileprivate func setupUserCard(_ cardViewModel: CardViewModel) {
        let cardView = CardView()
        cardView.cardViewModel = cardViewModel
        cardsDeckView.addSubview(cardView)
        cardView.fillSuperview()
    }
    
    @objc func handleSettings() {
        let registrationController = RegistrationController()
        present(registrationController, animated: true)
    }
    
    @objc func handleRefresh() {
        fetchUsers()
    }

}

