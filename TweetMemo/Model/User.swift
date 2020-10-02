//
//  User.swift
//
//  Created by Newton on 2020/05/09.
//  Copyright © 2020 Newton. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class User: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var fullname: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var profileText: String? = ""
    @objc dynamic var profileImage: Data? = nil
    
    var tweets = List<Tweet>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
