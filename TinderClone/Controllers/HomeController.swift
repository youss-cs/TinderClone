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
    var topCardView: CardView?
    var swipes = [String: Int]()
    
    fileprivate let hud = JGProgressHUD(style: .dark)
    fileprivate var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomStackView.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomStackView.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        
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
    
    fileprivate func setupLayout() {
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
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
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("Swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipes info for currently logged in user:", err)
                return
            }
            
            if let data = snapshot?.data() as? [String: Int] { self.swipes = data }
            self.fetchUsers()
        }
    }
    
    fileprivate func fetchUsers() {
        let minAge = user?.minSeekingAge ?? defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? defaultMaxSeekingAge
        topCardView = nil
        
        let query = Firestore.firestore().collection("Users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { (snapshot, error) in
            self.hud.dismiss()
            if let error = error{
                print(error.localizedDescription)
                return
            }
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let user = User(dictionary: documentSnapshot.data())
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                if isNotCurrentUser && hasNotSwipedBefore  {
                    let cardViewModel = CardViewModel(user: user)
                    self.cardViewModels.append(cardViewModel)
                    self.lastFetchUser = user
                    
                    let cardView = self.setupUserCard(cardViewModel)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    fileprivate func setupUserCard(_ cardViewModel: CardViewModel) -> CardView {
        let cardView = CardView()
        cardView.cardViewModel = cardViewModel
        cardView.delegate = self
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let nav = UINavigationController(rootViewController: settingsController)
        present(nav, animated: true)
    }
    
    @objc fileprivate func handleLike() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    @objc fileprivate func handleDislike() {
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let cardUID = topCardView?.cardViewModel?.uid else { return }
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("Swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe document:", err)
                return
            }
            
            if snapshot?.exists == true {
                Firestore.firestore().collection("Swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    
                    self.checkIfMatchExists(cardUID: cardUID)
                }
            } else {
                Firestore.firestore().collection("Swipes").document(uid).setData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    
                    self.checkIfMatchExists(cardUID: cardUID)
                }
            }
        }
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        Firestore.firestore().collection("Swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch document for card user:", err)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("Has matched")
            }
        }
    }

    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
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
    func didSwipe(didLike: Bool) {
        didLike ? handleLike() : handleDislike()
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }
}

