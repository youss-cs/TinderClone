//
//  User.swift
//  TinderClone
//
//  Created by YouSS on 4/12/19.
//  Copyright © 2019 YouSS. All rights reserved.
//

import Foundation

struct User {
    var id: String?
    var name: String?
    var age: Int?
    var profession: String?
    var imageUrl1: String?
    
    init(dictionary: [String : Any]) {
        id = dictionary["uid"] as? String
        name = dictionary["name"] as? String
        age = dictionary["age"] as? Int
        profession = dictionary["profession"] as? String
        imageUrl1 = dictionary["imageUrl1"] as? String
    }
}
