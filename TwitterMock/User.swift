//
//  User.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/19.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation
import Firebase

class User: NSObject {
   
    var id: String?
    var name: String?
    var email: String?
    var profileImage: String?
    

    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImage = dictionary["profileImage"] as? String
        
    }
}
