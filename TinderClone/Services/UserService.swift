//
//  UserService.swift
//  TinderClone
//
//  Created by YouSS on 4/16/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import Firebase

class UserService {
    
    static let shared = UserService()
    
    //MARK: Fetch User funcs
    
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("Users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                completion(nil, err)
                return
            }
            
            // fetched our user here
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user, nil)
        }
    }
}
