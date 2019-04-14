//
//  RegistrationViewModel.swift
//  TinderClone
//
//  Created by YouSS on 4/14/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableImage = Bindable<UIImage>()
    var bindableIsRegistring = Bindable<Bool>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var fullName: String? { didSet { isFormValid() } }
    var email: String? { didSet { isFormValid() } }
    var password: String? { didSet { isFormValid() } }
    
    fileprivate func isFormValid() {
        let isValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isValid
    }
    
    func performRegitration(completion: @escaping (Error?) -> Void) {
        guard let email = email, let password = password else { return }
        
        bindableIsRegistring.value = true
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(error)
                return
            }
            
            let filename = UUID().uuidString
            guard let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) else { return }
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let ref = Storage.storage().reference(withPath: "/images/\(filename)")
            ref.putData(imageData, metadata: metadata, completion: { (_, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                ref.downloadURL(completion: { (url, error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    print(url?.absoluteString)
                    self.bindableIsRegistring.value = false
                    completion(nil)
                })
            })
        }
    }
}
