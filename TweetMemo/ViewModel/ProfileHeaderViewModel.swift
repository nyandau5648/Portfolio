//
//  ProfileHeaderViewModel.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/10.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit
import RealmSwift

enum ProfileFilterOptions: Int, CaseIterable {
    
    case tweets
    case replies
    case likes
    
    var description: String {
        switch self {
        case .tweets: return "ツイート"
        case .replies: return "返信"
        case .likes: return "いいね"
        }
    }
    
}

struct ProfileHeaderViewModel {
    
    private let user: Results<User>!
    
    let usernameText: String
    
    init(user: Results<User>!){
        self.user = user
        self.usernameText = "@" + user[0].username
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSMutableAttributedString(string: "\(text)",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
    
}
