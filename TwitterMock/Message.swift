//
//  Message.swift
//  TwitterMock
//
//  Created by 陳 冠禎 on 2017/7/20.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {
   
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func chatPartnerId() -> String? {
        return  Auth.auth().currentUser?.uid == fromId ? toId : fromId
    }
}
