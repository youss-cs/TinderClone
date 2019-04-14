//
//  RegistrationViewModel.swift
//  TinderClone
//
//  Created by YouSS on 4/14/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import UIKit

class RegistrationViewModel {
    
    var fullName: String? { didSet { isFormValid() } }
    var email: String? { didSet { isFormValid() } }
    var password: String? { didSet { isFormValid() } }
    
    var isFormValidObserver: ((Bool) -> ())?
    
    fileprivate func isFormValid() {
        let isValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        isFormValidObserver?(isValid)
    }
}
