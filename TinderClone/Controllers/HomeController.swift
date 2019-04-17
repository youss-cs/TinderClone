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
    
    fileprivate let hud = JGProgressHUD(style: .dark)
    fileprivate var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        setupLayout()
        
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        
        fetchUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            let loginController = LoginController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            present(navController, animated: true)
        }
    }
    
    fileprivate func fetchUser() {
        UserService.shared.fetchCurrentUser { (user, error) in
            if let error = error {
                print("Failed to fetch user:", error)
                self.hud.dismiss()
                return
            }
            self.user = user
            self.fetchUsers()
        }
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
        guard let minAge = user?.minSeekingAge, let maxAge = user?.maxSeekingAge else { return }
        // i will introduce pagination here to page through 2 users at a time
        let query = Firestore.firestore().collection("Users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { (snapshot, error) in
            self.hud.dismiss()
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let user = User(dictionary: documentSnapshot.data())
                if user.id != Auth.auth().currentUser?.uid {
                    let cardViewModel = CardViewModel(user: user)
                    self.cardViewModels.append(cardViewModel)
                    self.setupUserCard(cardViewModel)
                    self.lastFetchUser = user
                }
            })
        }
    }
    
    fileprivate func setupUserCard(_ cardViewModel: CardViewModel) {
        let cardView = CardView()
        cardView.cardViewModel = cardViewModel
        cardView.delegate = self
        cardsDeckView.addSubview(cardView)
        cardView.fillSuperview()
    }
    
    
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let nav = UINavigationController(rootViewController: settingsController)
        present(nav, animated: true)
    }
    
    @objc func handleRefresh() {
        fetchUsers()
    }
}

extension HomeController: SettingsControllerDelegate {
    func didSaveSettings() {
        fetchUser()
    }
}

extension HomeController: LoginControllerDelegate {
    func didFinishLoggingIn() {
        fetchUser()
    }
}

extension HomeController: CardViewDelegate {
    func didTapMoreInfo() {
        let userDetailsController = UserDetailsController()
        present(userDetailsController, animated: true)
    }
}

