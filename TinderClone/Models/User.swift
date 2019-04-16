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
    var imageUrl2: String?
    var imageUrl3: String?
    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    
    init(dictionary: [String : Any]) {
        id = dictionary["uid"] as? String
        name = dictionary["name"] as? String
        age = dictionary["age"] as? Int
        profession = dictionary["profession"] as? String
        imageUrl1 = dictionary["imageUrl1"] as? String
        imageUrl2 = dictionary["imageUrl2"] as? String
        imageUrl3 = dictionary["imageUrl3"] as? String
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
    }
}
